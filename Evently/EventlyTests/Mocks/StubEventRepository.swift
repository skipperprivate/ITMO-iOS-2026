import Foundation
@testable import Evently

struct StubEventRepository: EventRepository {
    let events: [Event]
    let error: Error?

    init(
        events: [Event] = [],
        error: Error? = nil
    ) {
        self.events = events
        self.error = error
    }

    func fetchEvents() async throws -> [Event] {
        if let error {
            throw error
        }

        return events
    }

    func fetchEvents(
        category: EventCategoryRu
    ) async throws -> [Event] {
        let loadedEvents = try await fetchEvents()

        guard category != .all else {
            return loadedEvents
        }

        return loadedEvents.filter {
            $0.category == category
        }
    }
}
