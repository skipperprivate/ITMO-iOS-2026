import Foundation

protocol NewsStatisticsCalculating: Sendable {
    func calculate(texts: [String],
                   onProgress: @escaping @MainActor @Sendable (Double) -> Void) async throws -> NewsStatisticsResult
}

// Собственный actor выполняет CPU-работу вне MainActor.
// Передаются только строки: SwiftData-модели остаются в UI-слое.
actor NewsStatisticsService: NewsStatisticsCalculating {
    func calculate(texts: [String],
                   onProgress: @escaping @MainActor @Sendable (Double) -> Void) async throws -> NewsStatisticsResult {
        try Task.checkCancellation()
        var words = 0
        var characters = 0
        let step = max(1, texts.count / 100)
        for (index, text) in texts.enumerated() {
            try Task.checkCancellation()
            var insideWord = false
            for character in text {
                if characters.isMultiple(of: 1024) { try Task.checkCancellation() }
                characters += 1
                if character.isWhitespace {
                    insideWord = false
                } else if !insideWord {
                    words += 1
                    insideWord = true
                }
            }
            if (index + 1).isMultiple(of: step) || index + 1 == texts.count {
                await onProgress(Double(index + 1) / Double(texts.count))
            }
        }
        try Task.checkCancellation()
        await onProgress(1)
        return NewsStatisticsResult(articles: texts.count, words: words, characters: characters)
    }
}
