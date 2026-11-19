import Foundation

final class MockEventRepository: EventRepository {

    private let events: [Event]

    init(events: [Event] = MockEventFactory.events) {
        self.events = events
    }

    func fetchEvents() async throws -> [Event] {
        try await Task.sleep(for: .milliseconds(150))
        return events
    }

    func fetchEvents(category: EventCategoryRu) async throws -> [Event] {
        let loadedEvents = try await fetchEvents()

        guard category != .all else {
            return loadedEvents
        }

        return loadedEvents.filter { $0.category == category }
    }

    func fetchEvents(
        category: EventCategoryRu,
        page: Int,
        size: Int
    ) async throws -> EventPage {
        let filteredEvents = try await fetchEvents(category: category)
        return makePage(from: filteredEvents, page: page, size: size)
    }

    func searchEvents(
        keyword: String,
        page: Int,
        size: Int
    ) async throws -> EventPage {
        let query = keyword.trimmingCharacters(in: .whitespacesAndNewlines)

        let matchedEvents = events.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || $0.venue.localizedCaseInsensitiveContains(query)
                || $0.city.localizedCaseInsensitiveContains(query)
        }

        return makePage(from: matchedEvents, page: page, size: size)
    }

    private func makePage(
        from events: [Event],
        page: Int,
        size: Int
    ) -> EventPage {
        guard page >= 0, size > 0 else {
            return EventPage(events: [], page: page, hasMore: false)
        }

        let (start, overflow) = page.multipliedReportingOverflow(by: size)

        guard !overflow, start < events.count else {
            return EventPage(events: [], page: page, hasMore: false)
        }

        let items = Array(events.dropFirst(start).prefix(size))

        return EventPage(
            events: items,
            page: page,
            hasMore: items.count < events.count - start
        )
    }
}
