import Foundation

protocol EventRepository {
    func fetchEvents() async throws -> [Event]
    func fetchEvents(category: EventCategoryRu) async throws -> [Event]
    func fetchEvents(category: EventCategoryRu, page: Int, size: Int) async throws -> EventPage
    func searchEvents(keyword: String, page: Int, size: Int) async throws -> EventPage
    func fetchEventDetails(id: String) async throws -> Event?
}

extension EventRepository {
    func fetchEventDetails(id: String) async throws -> Event? { nil }

    func fetchEvents(category: EventCategoryRu) async throws -> [Event] {
        let events = try await fetchEvents()
        return category == .all ? events : events.filter { $0.category == category }
    }

    // Defaults keep lightweight test doubles source-compatible.
    // Real pagination and search are implemented in TicketmasterEventRepository.
    func fetchEvents(category: EventCategoryRu, page: Int, size: Int) async throws -> EventPage {
        let events = try await fetchEvents(category: category)
        return EventPage(events: page == 0 ? events : [], page: page, hasMore: false)
    }

    func searchEvents(keyword: String, page: Int, size: Int) async throws -> EventPage {
        EventPage(events: [], page: page, hasMore: false)
    }
}
