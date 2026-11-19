import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    var searchText = ""
    private(set) var filteredEvents: [Event] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasMore = false
    private(set) var errorMessage: String?
    private(set) var paginationError: String?

    private let repository: EventRepository
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    @ObservationIgnored private var paginationTask: Task<Void, Never>?
    @ObservationIgnored private var generation = UUID()
    @ObservationIgnored private var nextPage = 0

    init(repository: EventRepository) { self.repository = repository }

    var isSearchEmpty: Bool { searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func search() {
        searchTask?.cancel()
        paginationTask?.cancel()
        let id = UUID()
        generation = id
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        filteredEvents = []
        errorMessage = nil
        paginationError = nil
        hasMore = false
        isLoadingMore = false
        nextPage = 0
        isLoading = !keyword.isEmpty
        guard !keyword.isEmpty else { return }

        searchTask = Task {
            do {
                try await Task.sleep(for: EventCatalogConfiguration.searchDebounce)
                let result = try await repository.searchEvents(
                    keyword: keyword,
                    page: 0,
                    size: EventCatalogConfiguration.pageSize
                )
                try Task.checkCancellation()
                guard generation == id else { return }
                filteredEvents = deduplicated(result.events)
                hasMore = result.hasMore
                nextPage = result.page + 1
                isLoading = false
            } catch is CancellationError {
                return
            } catch {
                guard generation == id else { return }
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func requestNextPage() {
        guard hasMore, !isLoading, !isLoadingMore, !isSearchEmpty else { return }
        paginationTask = Task { await loadNextPage() }
    }

    func loadNextPage() async {
        guard hasMore, !isLoading, !isLoadingMore, !isSearchEmpty else { return }
        let id = generation
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let page = nextPage
        isLoadingMore = true
        paginationError = nil
        defer { if generation == id { isLoadingMore = false } }
        do {
            let result = try await repository.searchEvents(
                keyword: keyword,
                page: page,
                size: EventCatalogConfiguration.pageSize
            )
            try Task.checkCancellation()
            guard generation == id else { return }
            filteredEvents = deduplicated(filteredEvents + result.events)
            hasMore = result.hasMore
            nextPage = result.page + 1
        } catch is CancellationError {
            return
        } catch {
            guard generation == id else { return }
            paginationError = error.localizedDescription
        }
    }

    func retry() { search() }
    func clearSearch() { searchText = ""; search() }
    func cancel() {
        searchTask?.cancel()
        paginationTask?.cancel()
        generation = UUID()
        isLoading = false
        isLoadingMore = false
        hasMore = false
    }

    private func deduplicated(_ events: [Event]) -> [Event] {
        var seen = Set<UUID>()
        return events.filter { seen.insert($0.id).inserted }
    }
}
