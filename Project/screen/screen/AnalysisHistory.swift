import Foundation
import SwiftData

@Model
final class HistoryEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var title: String
    var detail: String

    init(_ event: AnalysisEvent) {
        id = event.id
        date = event.date
        title = event.title
        detail = event.detail
    }
}

@MainActor
final class AnalysisHistory {
    let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init(url: URL? = ScreenAnalysisStore.file("history.store"),
         legacy: URL? = ScreenAnalysisStore.file("events.json")) throws {
        guard let url else { throw CocoaError(.fileNoSuchFile) }
        container = try ModelContainer(for: HistoryEntry.self, configurations: ModelConfiguration(url: url))
        if let legacy,
           FileManager.default.fileExists(atPath: legacy.path) {
            let events = try JSONDecoder().decode([AnalysisEvent].self, from: Data(contentsOf: legacy))
            for event in events { context.insert(HistoryEntry(event)) }
            try context.save()
            try FileManager.default.removeItem(at: legacy)
        }
    }

    func append(_ event: AnalysisEvent) throws {
        context.insert(HistoryEntry(event))
        do { try context.save() } catch { context.rollback(); throw error }
    }

    func clear() throws {
        try context.delete(model: HistoryEntry.self)
        try context.save()
    }
}

extension ScreenAnalysisResult {
    func historyDetail(options: ScreenAnalysisOptions, status: String, account: RecordingAccount,
                       changes: Int, stableSeconds: Int) -> String {
        var fields = [
            "Visual changes this session: \(changes)",
            "Unchanged for: \(stableSeconds)s",
            "Text changed: \(textChanged ? "Yes" : "No")",
            "Text rule matched: \(textMatched ? "Yes" : "No")",
            "Screen condition met: \(matchesCondition(options) ? "Yes" : "No")",
            "Credit status: \(status)",
            "Qualified today: \(account.qualifiedSeconds ?? 0)s",
            "Screen credit earned today: \(account.earnedPoints ?? 0)%"
        ]
        if options.classifyImages, options.goodImageLabels?.isEmpty == false {
            fields.append("Good label confidence required: \(options.minimumLabelConfidence.formatted(.percent))")
        }
        if let change { fields.append("Pixel change: \(change.formatted(.percent.precision(.significantDigits(1...8))))") }
        if let templateScore {
            fields.append("Reference score: \(templateScore)")
            fields.append("Reference matched: \(templateScore >= options.matchThreshold ? "Yes" : "No")")
        }
        if let templateBounds { fields.append("Reference bounds (normalized): \(templateBounds)") }
        if let similarityDistance { fields.append("Full-screen feature distance: \(similarityDistance)") }
        if !language.isEmpty { fields.append("Language: \(language)") }
        fields.append("Recognized text:\n" + (text.isEmpty ? "None" : text))
        for (heading, values) in [("Detected links", links), ("QR / barcode contents", codes),
                                  ("Image labels", labels), ("Good labels matched", matchingLabels(options)), ("Recognition issues", warnings)] where !values.isEmpty {
            fields.append(heading + ":\n" + values.joined(separator: "\n"))
        }
        return fields.joined(separator: "\n\n")
    }
}
