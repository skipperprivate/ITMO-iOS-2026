import Foundation

protocol NewsSearching: Sendable {
    func search(documents: [NewsSearchDocument], query: String) async throws -> NewsSearchResult
}

struct NewsSearchService: NewsSearching {
    func search(
        documents: [NewsSearchDocument], query: String
    ) async throws -> NewsSearchResult {
        try Task.checkCancellation()
        let worker = Task.detached(priority: .userInitiated) {
            try scan(documents: documents, query: query)
        }
        return try await withTaskCancellationHandler {
            let result = try await worker.value
            try Task.checkCancellation()
            return result
        } onCancel: {
            worker.cancel()
        }
    }

    func scan(
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
        return NewsSearchResult(indices: matches)
    }
}
