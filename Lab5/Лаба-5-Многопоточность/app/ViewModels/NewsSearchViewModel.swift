import Foundation
import Observation

@MainActor
@Observable
final class NewsSearchViewModel {
    let documents: [NewsSearchDocument]
    var query = ""
    private(set) var matches: [Int] = []
    private(set) var isSearching = false
    private(set) var errorMessage: String?
    @ObservationIgnored private var activeID: UUID?

    init(documents: [NewsSearchDocument]) { self.documents = documents }

    func search(_ requestedQuery: String) async {
        let id = UUID()
        activeID = id
        matches = []
        errorMessage = nil
        guard !requestedQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isSearching = false
            return
        }
        isSearching = true
        do {
            // Debounce: ждём паузу в наборе, не блокируя поток.
            try await Task.sleep(for: .milliseconds(300))
            let result = try await NewsSearchService.search(documents: documents, query: requestedQuery)
            try Task.checkCancellation()
            guard activeID == id else { return }
            matches = result.indices
            isSearching = false
        } catch is CancellationError {
            // Старый запрос не должен менять состояние нового.
            if activeID == id { isSearching = false }
        } catch {
            guard activeID == id else { return }
            errorMessage = "Не удалось выполнить поиск: \(error.localizedDescription)"
            isSearching = false
        }
    }
}
