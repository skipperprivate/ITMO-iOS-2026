import Foundation
@testable import Evently

enum EventFixtures {
    static func makeEvent(index: Int = 0, category: EventCategoryRu = .music) -> Event {
        Event(
            id: UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", index + 1))!,
            title: "Событие \(index)",
            category: category,
            venue: "Тестовая площадка",
            city: "Москва",
            date: Date(timeIntervalSince1970: 1_800_000_000)
        )
    }

    static func makeEvents(count: Int) -> [Event] {
        (0..<count).map { makeEvent(index: $0) }
    }

    static let ticketmasterJSON = #"""
    {
      "id": "abc-123",
      "name": "Test Concert",
      "dates": {"start": {"dateTime": "2026-11-15T20:00:00Z"}},
      "classifications": [{"segment": {"name": "Music"}}],
      "_embedded": {"venues": [{"name": "Test Arena", "city": {"name": "Berlin"}}]},
      "priceRanges": [{"min": 25, "currency": "EUR"}]
    }
    """#
}
