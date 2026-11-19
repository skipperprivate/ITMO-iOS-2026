import CoreImage
import Foundation
import NaturalLanguage
import Vision

actor ScreenAnalyzer {
    private let context = CIContext(options: [.cacheIntermediates: false])
    private var previous: GrayImage?
    private var previousText = ""
    private var previousOptions: ScreenAnalysisOptions?
    private var reference: CGImage?
    private var referencePrint: VNFeaturePrintObservation?

    func reset() {
        previous = nil
        previousText = ""
    }

    func setReference(_ image: CGImage?) {
        reference = image
        referencePrint = image.flatMap { try? featurePrint($0) }
        previous = nil
        previousText = ""
    }

    func analyze(_ image: CGImage, options: ScreenAnalysisOptions) -> ScreenAnalysisResult {
        if previousOptions != options {
            previous = nil
            previousText = ""
            previousOptions = options
        }
        var result = ScreenAnalysisResult(image: image)
        if let gray = GrayImage(image: image, width: 48, height: 48) {
            result.change = previous.flatMap { gray.difference(from: $0) }
            previous = gray
        }
        let handler = VNImageRequestHandler(cgImage: image)
        if options.recognizeText { recognizeText(handler, result: &result) }
        if options.readCodes {
            do {
                let request = VNDetectBarcodesRequest()
                try handler.perform([request])
                result.codes = Array(Set((request.results ?? []).compactMap(\.payloadStringValue))).sorted()
            } catch { result.warnings.append("Barcode recognition: \(error.localizedDescription)") }
        }
        let sources = ([result.text] + result.codes).filter { !$0.isEmpty }
        result.textMatched = sources.contains(where: options.matches)
        result.text = sources.joined(separator: "\n")
        result.textChanged = result.text != previousText
        previousText = result.text
        if !result.text.isEmpty { analyzeText(&result) }
        if options.classifyImages {
            do {
                let request = VNClassifyImageRequest()
                try handler.perform([request])
                let suggestions = (request.results ?? []).filter { $0.confidence >= Float(ScreenAnalysisOptions.suggestionFloor) }.prefix(5)
                result.suggestedLabels = suggestions.map {
                    SuggestedImageLabel(identifier: $0.identifier, confidence: $0.confidence)
                }
            } catch { result.warnings.append("Image labels: \(error.localizedDescription)") }
        }
        if options.compareImages, let reference {
            let match = ScreenImageMatching.locate(reference, in: image)
            result.templateScore = match?.score
            result.templateBounds = match?.bounds
            if let referencePrint {
                do {
                    let current = try featurePrint(image)
                    var distance: Float = 0
                    try referencePrint.computeDistance(&distance, to: current)
                    result.similarityDistance = distance
                } catch { result.warnings.append("Image similarity: \(error.localizedDescription)") }
            }
        }
        return result
    }

    private func recognizeText(_ handler: VNImageRequestHandler, result: inout ScreenAnalysisResult) {
        do {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.automaticallyDetectsLanguage = true
            request.usesLanguageCorrection = true
            try handler.perform([request])
            result.text = (request.results ?? []).compactMap { $0.topCandidates(1).first }
                .filter { $0.confidence >= 0.3 }.map(\.string).joined(separator: "\n")
        } catch { result.warnings.append("Text recognition: \(error.localizedDescription)") }
    }

    private func analyzeText(_ result: inout ScreenAnalysisResult) {
        do {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(result.text)
            if let language = recognizer.dominantLanguage {
                result.language = Locale.current.localizedString(forLanguageCode: language.rawValue) ?? language.rawValue
            }
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            result.links = Array(Set(detector.matches(in: result.text, range: NSRange(result.text.startIndex..., in: result.text))
                .compactMap { $0.url?.absoluteString })).sorted()
        } catch { result.warnings.append("Link detection: \(error.localizedDescription)") }
    }

    func makeImage(_ buffer: ScreenFrame) -> CGImage? {
        guard let pixels = buffer.sample.imageBuffer else { return nil }
        let oriented = CIImage(cvPixelBuffer: pixels).oriented(forExifOrientation: buffer.orientation)
        let scale = min(1, 1600 / max(oriented.extent.width, oriented.extent.height))
        let image = oriented.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        return context.createCGImage(image, from: image.extent)
    }

    private func featurePrint(_ image: CGImage) throws -> VNFeaturePrintObservation {
        let request = VNGenerateImageFeaturePrintRequest()
        try VNImageRequestHandler(cgImage: image).perform([request])
        guard let result = request.results?.first as? VNFeaturePrintObservation else {
            throw NSError(domain: "ScreenAnalysis", code: 1, userInfo: [NSLocalizedDescriptionKey: "No image features found."])
        }
        return result
    }
}
