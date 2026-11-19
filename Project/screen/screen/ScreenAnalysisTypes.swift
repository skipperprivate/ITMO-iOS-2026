import Foundation
import CoreGraphics

nonisolated struct ScreenAnalysisOptions: Codable, Equatable, Sendable {
    var interval = 2.0
    var changeThreshold = 0.04
    private var includeUnchanged: Bool?
    var creditsUnchangedScreens: Bool {
        get { includeUnchanged ?? true }
        set { includeUnchanged = newValue }
    }
    var recognizeText = true
    var readCodes = true
    var classifyImages = false
    var goodImageLabels: Set<String>?
    static let suggestionFloor = 0.15
    private var labelConfidence: Double?
    var minimumLabelConfidence: Double {
        get { labelConfidence ?? Self.suggestionFloor }
        set { labelConfidence = newValue }
    }
    var compareImages = true
    var textPattern = ""
    var useRegex = false
    var requiredMatches = 2
    var matchThreshold = 0.94
    var automaticAI = false
    var aiUsesImage = false
    var aiQuestion = "Describe the visible activity briefly. Is it study, work, entertainment, or unknown? Explain the visible evidence."

    var patternError: String? {
        guard useRegex, !textPattern.isEmpty else { return nil }
        do {
            _ = try NSRegularExpression(pattern: textPattern, options: .caseInsensitive)
            return nil
        } catch { return "Invalid regular expression: \(error.localizedDescription)" }
    }

    func matches(_ text: String) -> Bool {
        let pattern = textPattern.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !pattern.isEmpty else { return false }
        if useRegex {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return false }
            return regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
        }
        return text.localizedCaseInsensitiveContains(pattern)
    }
}

nonisolated struct AnalysisEvent: Identifiable, Codable, Sendable {
    var id = UUID()
    var date = Date.now
    var title: String
    var detail: String
}

nonisolated struct SuggestedImageLabel: Sendable {
    let identifier: String
    let confidence: Float
}

nonisolated struct ScreenAnalysisResult: Sendable {
    var date = Date.now
    var image: CGImage
    var change: Double?
    var text = ""
    var textChanged = false
    var language = ""
    var links: [String] = []
    var codes: [String] = []
    var suggestedLabels: [SuggestedImageLabel] = []
    var labels: [String] {
        suggestedLabels.map { "\($0.identifier) (\(Int($0.confidence * 100))%)" }
    }
    var templateScore: Double?
    var templateBounds: CGRect?
    var similarityDistance: Float?
    var textMatched = false
    var warnings: [String] = []

    func matchingLabels(_ options: ScreenAnalysisOptions) -> [String] {
        guard options.classifyImages, let selected = options.goodImageLabels else { return [] }
        return suggestedLabels.filter {
            selected.contains($0.identifier) && $0.confidence >= Float(options.minimumLabelConfidence)
        }.map(\.identifier)
    }

    func matchesContent(_ options: ScreenAnalysisOptions) -> Bool {
        textMatched || (templateScore.map { $0 >= options.matchThreshold } ?? false) || !matchingLabels(options).isEmpty
    }

    func matchesCondition(_ options: ScreenAnalysisOptions) -> Bool {
        matchesContent(options) && (options.creditsUnchangedScreens || (change ?? 0) >= options.changeThreshold)
    }
}

/// Fires once after consecutive observations; rearms after a non-match.
nonisolated struct DetectionLatch {
    private(set) var count = 0
    private var fired = false
    mutating func observe(_ matches: Bool, required: Int) -> Bool {
        guard matches else { count = 0; fired = false; return false }
        count += 1
        guard count >= max(1, required), !fired else { return false }
        fired = true
        return true
    }
}

nonisolated enum ScreenAnalysisStore {
    static func file(_ name: String) -> URL? {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("ScreenAnalysis", isDirectory: true)
        guard let folder else { return nil }
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(name)
    }
    static var referenceURL: URL? { file("reference.image") }

    static func referenceData(at location: URL?) throws -> Data? {
        guard let url = location else { throw CocoaError(.fileNoSuchFile) }
        do { return try Data(contentsOf: url) }
        catch let error as CocoaError where error.code == .fileReadNoSuchFile { return nil }
    }

    static func saveReference(_ data: Data?, at location: URL?) throws {
        guard let url = location else { throw CocoaError(.fileNoSuchFile) }
        if let data {
            try data.write(to: url, options: [.atomic, .completeFileProtectionUnlessOpen])
        } else if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    static func load<T: Decodable>(_ type: T.Type, name: String) -> T? {
        guard let url = file(name), let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    static func save<T: Encodable>(_ value: T, name: String) {
        guard let url = file(name), let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url, options: [.atomic, .completeFileProtectionUnlessOpen])
    }
}
