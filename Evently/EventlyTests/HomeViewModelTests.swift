@testable import Evently
import Foundation
import Testing

@Suite("Home ViewModel")
@MainActor
struct HomeViewModelTests {

    @Test("First five events are featured; no duplicates in the list")
    func separatesFeatured() async {
        let events = EventFixtures.makeEvents(count: 6)
        let sut = HomeViewModel(
            repository: StubEventRepository(events: events)
        )

        await sut.load()

        #expect(
            sut.featuredEvents.map(\.id)
            == Array(events.prefix(5)).map(\.id)
        )
        #expect(sut.events.map(\.id) == [events[5].id])
        #expect(sut.errorMessage == nil)
        #expect(!sut.isLoading)
    }

    @Test("Repository failure sets error message")
    func loadFailure() async {
        let error = APIError.network(
            URLError(.notConnectedToInternet)
        )

        let repository = StubEventRepository(error: error)
        let sut = HomeViewModel(repository: repository)

        await sut.load()

        #expect(sut.errorMessage == error.localizedDescription)
        #expect(sut.featuredEvents.isEmpty)
        #expect(sut.events.isEmpty)
        #expect(!sut.isLoading)
    }

    @Test("Empty repository returns empty event lists")
    func loadEmptyEvents() async {
        let repository = StubEventRepository(events: [])
        let sut = HomeViewModel(repository: repository)

        await sut.load()

        #expect(sut.featuredEvents.isEmpty)
        #expect(sut.events.isEmpty)
        #expect(sut.errorMessage == nil)
        #expect(!sut.isLoading)
    }

    @Test("One event is displayed only in featured")
    func loadSingleEvent() async {
        let events = EventFixtures.makeEvents(count: 1)
        let sut = HomeViewModel(
            repository: StubEventRepository(events: events)
        )

        await sut.load()

        #expect(sut.featuredEvents.count == 1)
        #expect(sut.featuredEvents.first?.id == events[0].id)
        #expect(sut.events.isEmpty)
        #expect(sut.errorMessage == nil)
        #expect(!sut.isLoading)
    }

    @Test("Five events fit entirely into featured")
    func loadExactlyFiveEvents() async {
        let events = EventFixtures.makeEvents(count: 5)
        let sut = HomeViewModel(
            repository: StubEventRepository(events: events)
        )

        await sut.load()

        #expect(sut.featuredEvents.map(\.id) == events.map(\.id))
        #expect(sut.events.isEmpty)
        #expect(sut.errorMessage == nil)
        #expect(!sut.isLoading)
    }

    @Test("Featured events disappear when leaving the All category")
    func clearsFeaturedAfterCategoryChange() async {
        let events = EventFixtures.makeEvents(count: 6)
        let sut = HomeViewModel(repository: StubEventRepository(events: events))

        await sut.load()
        #expect(!sut.featuredEvents.isEmpty)

        sut.selectCategory(.music)
        await sut.load()

        #expect(sut.featuredEvents.isEmpty)
    }

}
