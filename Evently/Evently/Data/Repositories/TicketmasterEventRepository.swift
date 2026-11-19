import Foundation

@MainActor
final class TicketmasterEventRepository: EventRepository {
    private let apiClient: TicketmasterAPIClient
    private let locationStore: LocationStore

    init(
        apiClient: TicketmasterAPIClient,
        locationStore: LocationStore
    ) {
        self.apiClient = apiClient
        self.locationStore = locationStore
    }

    func fetchEvents() async throws -> [Event] {
        try await fetchEvents(category: .all, page: 0, size: EventCatalogConfiguration.pageSize).events
    }

    func fetchEvents(category: EventCategoryRu) async throws -> [Event] {
        try await fetchEvents(category: category, page: 0, size: EventCatalogConfiguration.pageSize).events
    }

    func fetchEvents(category: EventCategoryRu, page: Int, size: Int) async throws -> EventPage {
        let response = try await apiClient.fetchEvents(
            countryCode: locationStore.countryCode ?? EventCatalogConfiguration.defaultCountryCode,
            page: page,
            size: size,
            segmentId: segmentId(for: category),
            city: locationStore.city
        )
        let mapped = (response.embedded?.events ?? []).compactMap {
            TicketmasterEventMapper.map($0)
        }
        let events = category == .all ? mapped : mapped.filter { $0.category == category }
        return makePage(events: events, response: response, requestedPage: page, size: size)
    }

    func searchEvents(keyword: String, page: Int, size: Int) async throws -> EventPage {
        let response = try await apiClient.fetchEvents(
            countryCode: locationStore.countryCode ?? EventCatalogConfiguration.defaultCountryCode,
            page: page,
            size: size,
            keyword: keyword,
            city: locationStore.city
        )
        let events = (response.embedded?.events ?? []).compactMap {
            TicketmasterEventMapper.map($0)
        }
        return makePage(events: events, response: response, requestedPage: page, size: size)
    }

    func fetchEventDetails(id: String) async throws -> Event? {
        let dto = try await apiClient.fetchEventDetails(id: id)
        return TicketmasterEventMapper.map(dto)
    }

    private func makePage(events: [Event], response: TicketmasterResponseDTO,
                          requestedPage: Int, size: Int) -> EventPage {
        let currentPage = response.page?.number ?? requestedPage
        // Ticketmaster caps deep paging to the first 1000 results.
        let withinLimit = (currentPage + 1) * size < EventCatalogConfiguration.ticketmasterResultWindow
        let hasMore = response.page.map { currentPage + 1 < $0.totalPages } ?? false
        return EventPage(events: events, page: currentPage, hasMore: hasMore && withinLimit)
    }

    private func segmentId(for category: EventCategoryRu) -> String? {
        switch category {
        case .all, .other: return nil
        case .music: return "KZFzniwnSyZfZ7v7nJ"
        case .sport: return "KZFzniwnSyZfZ7v7nE"
        case .arts: return "KZFzniwnSyZfZ7v7na"
        case .film: return "KZFzniwnSyZfZ7v7nn"
        case .miscellaneous: return "KZFzniwnSyZfZ7v7n1"
        }
    }
}
