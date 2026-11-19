import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let repository: EventRepository

    var featuredEvents: [Event] = []
    var events: [Event] = []
    var selectedCategory: EventCategoryRu = .all
    var isLoading = false
    var isLoadingMore = false
    var hasMore = false
    var errorMessage: String?
    var paginationError: String?

    @ObservationIgnored private var requestID = UUID()
    @ObservationIgnored private var nextPage = 0
    @ObservationIgnored private var paginationTask: Task<Void, Never>?

    init(repository: EventRepository) {
        self.repository = repository
    }

    var filteredEvents: [Event] { events }

    func load() async {
        paginationTask?.cancel()
        let id = UUID()
        requestID = id
        let category = selectedCategory
        isLoading = true
        isLoadingMore = false
        errorMessage = nil
        paginationError = nil
        hasMore = false
        nextPage = 0
        events = []
        featuredEvents = []
        defer { if requestID == id { isLoading = false } }

        do {
            let result = try await repository.fetchEvents(
                category: category,
                page: 0,
                size: EventCatalogConfiguration.pageSize
            )
            try Task.checkCancellation()
            guard requestID == id else { return }

            if category == .all {
                featuredEvents = Array(result.events.prefix(EventCatalogConfiguration.featuredEventsCount))
            }
            let featuredIDs = Set(featuredEvents.map(\.id))
            events = deduplicated(result.events).filter { !featuredIDs.contains($0.id) }
            hasMore = result.hasMore
            nextPage = result.page + 1
        } catch is CancellationError {
            return
        } catch {
            guard requestID == id else { return }
            errorMessage = error.localizedDescription
        }
    }

    func requestNextPage() {
        guard hasMore, !isLoading, !isLoadingMore else { return }
        paginationTask = Task { await loadNextPage() }
    }

    func loadNextPage() async {
        guard hasMore, !isLoading, !isLoadingMore else { return }
        let id = requestID
        let category = selectedCategory
        let page = nextPage
        isLoadingMore = true
        paginationError = nil
        defer { if requestID == id { isLoadingMore = false } }

        do {
            let result = try await repository.fetchEvents(
                category: category,
                page: page,
                size: EventCatalogConfiguration.pageSize
            )
            try Task.checkCancellation()
            guard requestID == id else { return }
            let featuredIDs = Set(featuredEvents.map(\.id))
            events = deduplicated(events + result.events).filter { !featuredIDs.contains($0.id) }
            hasMore = result.hasMore
            nextPage = result.page + 1
        } catch is CancellationError {
            return
        } catch {
            guard requestID == id else { return }
            paginationError = error.localizedDescription
        }
    }

    func selectCategory(_ category: EventCategoryRu) {
        guard selectedCategory != category else { return }
        selectedCategory = category
    }

    private func deduplicated(_ events: [Event]) -> [Event] {
        var seen = Set<UUID>()
        return events.filter { seen.insert($0.id).inserted }
    }
}
