import CoreImage.CIFilterBuiltins
import UIKit
import CoreGraphics
import Foundation
import Testing
@testable import screen

struct ScreenAnalysisTests {
    @MainActor @Test func referenceSurvivesRelaunchAndRemoval() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        let data = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8)).pngData { _ in
            UIColor.red.setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: 8, height: 8))
        }
        let first = ScreenAnalysisModel(referenceURL: url)
        await first.setReference(data: data)
        let reopened = ScreenAnalysisModel(referenceURL: url)
        #expect(reopened.reference != nil)
        await reopened.setReference(data: nil)
        #expect(ScreenAnalysisModel(referenceURL: url).reference == nil)
    }

    @MainActor @Test(arguments: [true, false])
    func matchedFullScreenAccumulatesSeconds(textRule: Bool) async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        let rendered = UIGraphicsImageRenderer(size: CGSize(width: 320, height: 200)).image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: 320, height: 200))
            ("LESSON COMPLETE" as NSString).draw(at: CGPoint(x: 10, y: 8), withAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 26), .foregroundColor: UIColor.black
            ])
        }
        let image = try #require(rendered.cgImage)
        let analyzer = ScreenAnalyzer()
        var options = ScreenAnalysisOptions()
        options.textPattern = textRule ? "LESSON COMPLETE" : ""
        options.recognizeText = textRule
        options.readCodes = false
        if !textRule { await analyzer.setReference(image) }
        let result = await analyzer.analyze(image, options: options)
        #expect(result.matchesCondition(options))
        let still = await analyzer.analyze(image, options: options)
        #expect(still.change == 0)
        #expect(still.matchesCondition(options))
        options.creditsUnchangedScreens = false
        #expect(!still.matchesCondition(options))
        var changed = still
        changed.change = options.changeThreshold
        #expect(changed.matchesCondition(options))
        options.creditsUnchangedScreens = true
        var config = BatteryConfig()
        config.credit.mode = .screen
        let usage = MatchedUsage(accountURL: url)
        usage.configure(config)
        let start = Calendar.current.startOfDay(for: .now) + 1
        for offset in [0, 2, 4] {
            _ = try usage.observe(result, at: start + Double(offset), options: options)
        }
        let saved = try RecordingAccounting.read(day: DailyUsage.today, at: url)
        #expect(saved.sessions?[usage.sessionID]?.matched == 4)
        #expect(saved.sessions?[usage.sessionID]?.qualified == 4)
        #expect(saved.qualifiedSeconds == 4)
        #expect(saved.total == 4.0 / 60)
    }

    @MainActor @Test func onlySelectedSuggestedLabelsEarnTime() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        let frame = try image(width: 8, height: 8) { _ in }
        var result = ScreenAnalysisResult(image: frame)
        result.suggestedLabels = [.init(identifier: "book", confidence: 0.7), .init(identifier: "paper", confidence: 0.99)]
        var options = ScreenAnalysisOptions()
        options.goodImageLabels = ["book"]
        #expect(!result.matchesCondition(options))
        options.classifyImages = true
        #expect(options.minimumLabelConfidence == 0.15)
        options.minimumLabelConfidence = 0.71
        #expect(!result.matchesCondition(options))
        #expect(result.labels.count == 2)
        options.minimumLabelConfidence = 0.70
        options = try JSONDecoder().decode(ScreenAnalysisOptions.self, from: JSONEncoder().encode(options))
        #expect(options.minimumLabelConfidence == 0.70)
        #expect(result.matchingLabels(options) == ["book"])
        let usage = MatchedUsage(accountURL: url)
        var config = BatteryConfig()
        config.credit.mode = .screen
        usage.configure(config)
        let start = Calendar.current.startOfDay(for: .now) + 1
        for offset in [0, 2, 4] {
            _ = try usage.observe(result, at: start + Double(offset), options: options)
        }
        result.suggestedLabels = [.init(identifier: "bookshelf", confidence: 1)]
        #expect(!result.matchesCondition(options))
        _ = try usage.observe(result, at: start + 6, options: options)
        let account = try RecordingAccounting.read(day: DailyUsage.today, at: url)
        #expect(account.qualifiedSeconds == 4)
        #expect(account.total == 4.0 / 60 * config.goodRate)
    }

    @MainActor @Test func qrPayloadFeedsTextRuleWithOCROff() async throws {
        let code = CIFilter.qrCodeGenerator()
        code.message = Data("lesson-42".utf8)
        let qr = try #require(code.outputImage)
        let scaled = qr.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        let background = CIImage(color: .white).cropped(to: scaled.extent.insetBy(dx: -40, dy: -40))
        let image = try #require(CIContext().createCGImage(scaled.composited(over: background), from: background.extent))
        let analyzer = ScreenAnalyzer()
        var options = ScreenAnalysisOptions()
        options.recognizeText = false
        options.textPattern = #"^lesson-\d+$"#
        options.useRegex = true
        let result = await analyzer.analyze(image, options: options)
        #expect(result.text == "lesson-42")
        #expect(result.matchesCondition(options))
        options.readCodes = false
        let disabled = await analyzer.analyze(image, options: options)
        #expect(disabled.text.isEmpty)
        #expect(!disabled.matchesCondition(options))
    }

    @Test func ruleMatchingAndInvalidRegex() {
        var options = ScreenAnalysisOptions()
        #expect(!options.matches("Completed"))
        options.textPattern = "completed"
        #expect(options.matches("Exercise COMPLETED successfully"))
        #expect(!options.matches("Complete the exercise"))
        options.useRegex = true
        options.textPattern = #"Score:\s*(100|[9][0-9])%"#
        #expect(options.matches("Score: 95%"))
        #expect(!options.matches("Score: 50%"))
        options.textPattern = "["
        #expect(options.patternError != nil)
        #expect(!options.matches("anything"))
    }

    @Test func confirmationDeduplicatesAndRearms() {
        var latch = DetectionLatch()
        let observations = [true, true, true, false, true, true].map { latch.observe($0, required: 2) }
        #expect(observations == [false, true, false, false, false, true])
    }

    @Test func nonConsecutiveMatchesDoNotTrigger() {
        var latch = DetectionLatch()
        let observations = (0..<10).map { latch.observe($0.isMultiple(of: 2), required: 2) }
        #expect(observations.allSatisfy { !$0 })
    }

    @Test func changedPixelsAndEmbeddedImage() throws {
        let screen = try image(width: 120, height: 160) { context in
            context.setFillColor(CGColor(gray: 0.1, alpha: 1))
            context.fill(CGRect(x: 0, y: 0, width: 120, height: 160))
            context.setFillColor(CGColor(gray: 1, alpha: 1))
            context.fill(CGRect(x: 40, y: 50, width: 24, height: 32))
            context.setFillColor(CGColor(gray: 0, alpha: 1))
            context.fill(CGRect(x: 44, y: 54, width: 12, height: 10))
        }
        // CGImage cropping coordinates are used consistently by matcher and capture analyzer.
        let reference = try #require(screen.cropping(to: CGRect(x: 40, y: 78, width: 24, height: 32)))
        let match = try #require(ScreenImageMatching.locate(reference, in: screen))
        #expect(match.score > 0.99)
        #expect(abs(match.bounds.width - 0.2) < 0.02)
        let gray = try #require(GrayImage(image: screen, width: 48, height: 48))
        #expect(gray.difference(from: gray) == 0)
        let blank = try image(width: 120, height: 160) { context in
            context.setFillColor(CGColor(gray: 1, alpha: 1))
            context.fill(CGRect(x: 0, y: 0, width: 120, height: 160))
        }
        let other = try #require(GrayImage(image: blank, width: 48, height: 48))
        #expect(try #require(gray.difference(from: other)) > 0.5)
        let mismatch = try #require(ScreenImageMatching.locate(reference, in: blank))
        #expect(mismatch.score < 0.94)
    }

    @Test func previousRegionAndFaceSettingsAreIgnored() throws {
        var options = ScreenAnalysisOptions()
        options.textPattern = "finished"
        var json = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(options)) as? [String: Any])
        json["region"] = "Bottom half"
        json["countFaces"] = true
        let restored = try JSONDecoder().decode(ScreenAnalysisOptions.self, from: JSONSerialization.data(withJSONObject: json))
        #expect(restored == options)
    }

    private func image(width: Int, height: Int, draw: (CGContext) -> Void) throws -> CGImage {
        let context = try #require(CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                           bytesPerRow: width, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: 0))
        draw(context)
        return try #require(context.makeImage())
    }
}
