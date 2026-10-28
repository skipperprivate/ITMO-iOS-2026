import Foundation

enum NewsSearchService {
    nonisolated static func search(
        documents: [NewsSearchDocument], query: String
    ) async throws -> NewsSearchResult {
        try Task.checkCancellation()
        // Обычный Task внутри UI может унаследовать MainActor.
        // detached изолирует синхронную обработку строк от UI-актора.
        let worker = Task.detached(priority: .userInitiated) {
            try scan(documents: documents, query: query)
        }
        // У detached нет автоматической отмены вместе с родителем:
        // передаём её явно при смене запроса или закрытии экрана.
        return try await withTaskCancellationHandler {
            let result = try await worker.value
            try Task.checkCancellation()
            return result
        } onCancel: {
            worker.cancel()
        }
    }

    nonisolated static func scan(
        documents: [NewsSearchDocument], query: String
    ) throws -> NewsSearchResult {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var matches: [Int] = []
        for (index, document) in documents.enumerated() {
            try Task.checkCancellation()
            if needle.isEmpty
                || document.title.localizedCaseInsensitiveContains(needle)
                || document.text.localizedCaseInsensitiveContains(needle) {
                matches.append(index)
            }
        }
        try Task.checkCancellation()
        return (matches, !Thread.isMainThread)
    }
}
