//import Foundation
//import Testing
//@testable import Evently
//
//@Suite("Evently unit tests")
//struct EventlyTests {
//
//    @Test("Ticketmaster DTO maps to Event and keeps stable ID")
//    func mapperCreatesEvent() throws {
//        let json = #"""
//        {
//          "id": "abc-123",
//          "name": "Test Concert",
//          "dates": {"start": {"dateTime": "2026-11-15T20:00:00Z"}},
//          "classifications": [{"segment": {"name": "Music"}}],
//          "_embedded": {"venues": [{"name": "Test Arena", "city": {"name": "Berlin"}}]},
//          "priceRanges": [{"min": 25, "currency": "EUR"}]
//        }
//        """#
//        let dto = try JSONDecoder().decode(
//            TicketmasterEventDTO.self,
//            from: Data(json.utf8)
//        )
//        let first = try #require(TicketmasterEventMapper.map(dto))
//        let second = try #require(TicketmasterEventMapper.map(dto))
//
//        #expect(first.title == "Test Concert")
//        #expect(first.category == .music)
//        #expect(first.venue == "Test Arena")
//        #expect(first.city == "Berlin")
//        #expect(first.id == second.id)
//        #expect(first.price?.contains("EUR") == true)
//    }
//
//    @Test("HomeViewModel separates first five featured events")
//    @MainActor
//    func homeSeparatesFeatured() async {
//        let items = (0..<6).map { index in
//            Event(
//                title: "Event \(index)",
//                category: .music,
//                venue: "Venue",
//                city: "Berlin",
//                date: Date(timeIntervalSince1970: 1_800_000_000)
//            )
//        }
//        let sut = HomeViewModel(repository: StubEventRepository(items: items))
//
//        await sut.load()
//
//        #expect(sut.featuredEvents.count == 5)
//        #expect(sut.events.count == 1)
//        #expect(sut.events.first?.id == items[5].id)
//        #expect(sut.errorMessage == nil)
//        #expect(!sut.isLoading)
//    }
//
//    @Test("FeedbackViewModel trims input and marks submission successful")
//    @MainActor
//    func feedbackSubmission() async {
//        let spy = FeedbackRepositorySpy()
//        let sut = FeedbackViewModel(repository: spy)
//        sut.title = "  Ошибка  "
//        sut.message = "  Описание  "
//
//        await sut.submit()
//        let payload = await spy.submittedPayload()
//
//        #expect(payload?.title == "Ошибка")
//        #expect(payload?.message == "Описание")
//        #expect(sut.isSuccess)
//        #expect(sut.title.isEmpty)
//        #expect(sut.message.isEmpty)
//        #expect(!sut.isSending)
//    }
//}
//
//private struct StubEventRepository: EventRepository {
//    let items: [Event]
//
//    func fetchEvents() async throws -> [Event] { items }
//
//    func fetchEvents(category: EventCategoryRu) async throws -> [Event] {
//        category == .all ? items : items.filter { $0.category == category }
//    }
//}
//
//private actor FeedbackRepositorySpy: FeedbackRepository {
//    private var payload: (title: String, message: String)?
//
//    func sendFeedback(title: String, message: String) async throws {
//        payload = (title, message)
//    }
//
//    func submittedPayload() -> (title: String, message: String)? {
//        payload
//    }
//}
