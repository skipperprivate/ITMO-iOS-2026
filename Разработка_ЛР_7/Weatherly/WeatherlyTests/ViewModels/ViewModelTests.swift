//
//  ViewModelTests.swift
//  WeatherlyTests
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import XCTest
@testable import Weatherly

@MainActor
final class CityDetailViewModelTests: XCTestCase {
    private final class Clock: @unchecked Sendable {
        var now = Date(timeIntervalSince1970: 1_790_700_000)
    }

    func testLoadsSnapshot() async {
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: StubWeatherRepository())

        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.snapshot?.city, TestCities.moscow)
        XCTAssertNil(viewModel.refreshError)
        XCTAssertNotNil(viewModel.lastUpdated)
    }

    func testFirstLoadFailureIsShownAsFailedState() async {
        let viewModel = CityDetailViewModel(
            city: TestCities.moscow,
            weatherRepository: StubWeatherRepository { _ in throw RepositoryError.offline }
        )

        await viewModel.loadIfNeeded()

        guard case .failed(let error) = viewModel.state else {
            return XCTFail("Expected failed state, got \(viewModel.state)")
        }
        XCTAssertEqual(error, .offline)
    }

    func testUnexpectedErrorsBecomeUnknown() async {
        let viewModel = CityDetailViewModel(
            city: TestCities.moscow,
            weatherRepository: StubWeatherRepository { _ in throw URLError(.badURL) }
        )

        await viewModel.loadIfNeeded()

        guard case .failed(let error) = viewModel.state else {
            return XCTFail("Expected failed state")
        }
        XCTAssertEqual(error, .unknown)
    }

    // Stale-while-revalidate: a failed refresh keeps the data and reports itself separately.
    func testFailedRefreshKeepsDataAndSetsBannerError() async {
        let repository = StubWeatherRepository()
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: repository)
        await viewModel.loadIfNeeded()
        let loaded = viewModel.snapshot

        repository.respond { _ in throw RepositoryError.timedOut }
        await viewModel.refresh()

        XCTAssertEqual(viewModel.snapshot, loaded)
        XCTAssertEqual(viewModel.refreshError, .timedOut)
    }

    func testSuccessfulRefreshClearsBannerError() async {
        let repository = StubWeatherRepository()
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: repository)
        await viewModel.loadIfNeeded()
        repository.respond { _ in throw RepositoryError.offline }
        await viewModel.refresh()

        repository.respond { MockData.snapshot(for: $0) }
        await viewModel.recoverAfterReconnect()

        XCTAssertNil(viewModel.refreshError)
        XCTAssertEqual(repository.callCount, 3)
    }

    func testLoadIfNeededSkipsFreshDataAndReloadsStaleData() async {
        let clock = Clock()
        let repository = StubWeatherRepository()
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: repository, now: { clock.now })

        await viewModel.loadIfNeeded()
        clock.now += CityDetailViewModel.staleInterval - 1
        await viewModel.loadIfNeeded()
        XCTAssertEqual(repository.callCount, 1)

        clock.now += 2
        await viewModel.loadIfNeeded()
        XCTAssertEqual(repository.callCount, 2)
    }

    func testRecoverAfterReconnectDoesNothingWhenHealthy() async {
        let repository = StubWeatherRepository()
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: repository)
        await viewModel.loadIfNeeded()

        await viewModel.recoverAfterReconnect()

        XCTAssertEqual(repository.callCount, 1)
    }

    // Appearance and pull-to-refresh at the same moment must not fire two requests.
    func testOverlappingLoadsShareOneRequest() async {
        let repository = StubWeatherRepository()
        repository.hold()
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: repository)

        async let first: Void = viewModel.loadIfNeeded()
        async let second: Void = viewModel.refresh()
        _ = await waitUntil { repository.callCount == 1 }
        repository.release()
        _ = await (first, second)

        XCTAssertEqual(repository.callCount, 1)
        XCTAssertNotNil(viewModel.snapshot)
    }
}

@MainActor
final class PlacesViewModelTests: XCTestCase {
    private func makeViewModel(
        cities: [City] = [TestCities.moscow, TestCities.kazan, TestCities.sochi],
        weather: StubWeatherRepository
    ) -> PlacesViewModel {
        PlacesViewModel(favoritesRepository: InMemoryFavoritesRepository(initialCities: cities), weatherRepository: weather)
    }

    func testLoadsWeatherForEveryCity() async {
        let viewModel = makeViewModel(weather: StubWeatherRepository())

        await viewModel.load()

        XCTAssertEqual(viewModel.cities.count, 3)
        for city in viewModel.cities {
            guard case .loaded = viewModel.weather(for: city) else {
                return XCTFail("\(city.name) has no weather")
            }
        }
        XCTAssertNil(viewModel.weatherError)
    }

    func testFailedCityIsUnavailableNotSpinning() async {
        let weather = StubWeatherRepository { city in
            if city == TestCities.kazan { throw RepositoryError.timedOut }
            return MockData.snapshot(for: city)
        }
        let viewModel = makeViewModel(weather: weather)

        await viewModel.load()

        XCTAssertEqual(viewModel.weather(for: TestCities.kazan), .unavailable)
        guard case .loaded = viewModel.weather(for: TestCities.moscow) else {
            return XCTFail("Moscow should still load")
        }
        XCTAssertNil(viewModel.weatherError, "Partial failure is shown per card only")
    }

    func testEveryCityFailingSetsBannerErrorAndKeepsLoadedCards() async {
        let weather = StubWeatherRepository()
        let viewModel = makeViewModel(weather: weather)
        await viewModel.load()

        weather.respond { _ in throw RepositoryError.offline }
        await viewModel.refreshWeather()

        XCTAssertEqual(viewModel.weatherError, .offline)
        guard case .loaded = viewModel.weather(for: TestCities.sochi) else {
            return XCTFail("Shown weather must survive a failed refresh")
        }
    }

    func testRemoveUpdatesListAndStorage() async throws {
        let favorites = InMemoryFavoritesRepository(initialCities: [TestCities.moscow, TestCities.kazan])
        let viewModel = PlacesViewModel(favoritesRepository: favorites, weatherRepository: StubWeatherRepository())
        await viewModel.load()

        viewModel.remove(at: IndexSet(integer: 0))

        XCTAssertEqual(viewModel.cities, [TestCities.kazan])
        let stored = await waitForFavorites(favorites) { $0 == [TestCities.kazan] }
        XCTAssertTrue(stored)
    }

    func testMoveKeepsScreenAndStorageInSameOrder() async throws {
        let favorites = InMemoryFavoritesRepository(initialCities: [TestCities.moscow, TestCities.kazan, TestCities.sochi])
        let viewModel = PlacesViewModel(favoritesRepository: favorites, weatherRepository: StubWeatherRepository())
        await viewModel.load()

        viewModel.move(from: IndexSet(integer: 0), to: 3)

        XCTAssertEqual(viewModel.cities, [TestCities.kazan, TestCities.sochi, TestCities.moscow])
        let stored = await waitForFavorites(favorites) { $0 == viewModel.cities }
        XCTAssertTrue(stored)
    }

    private func waitForFavorites(_ repository: InMemoryFavoritesRepository, _ condition: @escaping ([City]) -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(2)
        while Date() < deadline {
            if let cities = try? await repository.loadFavorites(), condition(cities) { return true }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        return false
    }
}

@MainActor
final class SearchViewModelTests: XCTestCase {
    func testShortQueryShowsHintWithoutRequest() async {
        let repository = StubGeocodingRepository()
        let viewModel = SearchViewModel(geocodingRepository: repository)

        viewModel.query = "к"

        XCTAssertEqual(viewModel.state, .tooShort(minimumLength: 2))
        XCTAssertFalse(viewModel.isSearching)
        try? await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertTrue(repository.receivedQueries.isEmpty)
    }

    // Debounce: fast typing results in a single request for the final text.
    func testTypingIsDebouncedIntoOneRequest() async {
        let repository = StubGeocodingRepository(result: .success([TestCities.kazan]))
        let viewModel = SearchViewModel(geocodingRepository: repository)

        for text in ["ка", "каз", "каза", "казань"] {
            viewModel.query = text
        }
        let finished = await waitUntil { viewModel.state == .results([TestCities.kazan]) }

        XCTAssertTrue(finished)
        XCTAssertEqual(repository.receivedQueries, ["казань"])
        XCTAssertFalse(viewModel.isSearching)
    }

    func testNothingFoundIsEmpty() async {
        let viewModel = SearchViewModel(geocodingRepository: StubGeocodingRepository(result: .success([])))

        viewModel.query = "zzqqxx"

        let finished = await waitUntil { viewModel.state == .empty }
        XCTAssertTrue(finished)
    }

    func testFailureAndRetry() async {
        let repository = StubGeocodingRepository(result: .failure(.offline))
        let viewModel = SearchViewModel(geocodingRepository: repository)

        viewModel.query = "казань"
        let failed = await waitUntil { viewModel.state == .failed(.offline) }
        XCTAssertTrue(failed)

        repository.respond(with: .success([TestCities.kazan]))
        viewModel.retry()
        let recovered = await waitUntil { viewModel.state == .results([TestCities.kazan]) }
        XCTAssertTrue(recovered)
    }

    func testClearingQueryReturnsToIdle() async {
        let viewModel = SearchViewModel(geocodingRepository: StubGeocodingRepository())

        viewModel.query = "казань"
        viewModel.query = "  "

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertFalse(viewModel.isSearching)
        XCTAssertFalse(viewModel.isActive)
    }
}

@MainActor
final class DayDetailViewModelTests: XCTestCase {
    func testSlicesDayAndItsHoursFromSnapshot() {
        let snapshot = MockData.snapshot(for: TestCities.moscow)
        let day = snapshot.daily[2]

        let viewModel = DayDetailViewModel(snapshot: snapshot, date: day.date.addingTimeInterval(3600))

        guard case .loaded(let loadedDay, let hours) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }
        XCTAssertEqual(loadedDay, day)
        XCTAssertEqual(hours.count, 24)
        XCTAssertTrue(hours.allSatisfy { TestCities.moscow.calendar.isDate($0.date, inSameDayAs: day.date) })
    }

    func testDateOutsideForecastIsUnavailable() {
        let snapshot = MockData.snapshot(for: TestCities.moscow)

        let viewModel = DayDetailViewModel(snapshot: snapshot, date: .distantFuture)

        guard case .unavailable = viewModel.state else {
            return XCTFail("Expected unavailable state")
        }
    }
}

final class PresentationTests: XCTestCase {
    func testUpdatedAgo() {
        let now = Date(timeIntervalSince1970: 1_790_700_000)
        XCTAssertEqual(WeatherFormatter.updated(at: now, now: now), "Обновлено только что")
        XCTAssertEqual(WeatherFormatter.updated(at: now - 60, now: now), "Обновлено 1 минуту назад")
        XCTAssertEqual(WeatherFormatter.updated(at: now - 3 * 60, now: now), "Обновлено 3 минуты назад")
        XCTAssertEqual(WeatherFormatter.updated(at: now - 11 * 60, now: now), "Обновлено 11 минут назад")
        XCTAssertEqual(WeatherFormatter.updated(at: now - 2 * 3600, now: now), "Обновлено 2 часа назад")
        XCTAssertEqual(WeatherFormatter.updated(at: now - 30 * 3600, now: now), "Обновлено давно")
    }

    func testNowTileShowsCurrentReadingNotTopOfHourForecast() {
        let snapshot = MockData.snapshot(for: TestCities.moscow)
        let hours = Array(snapshot.hourly.prefix(3))

        let entries = HourlyTimeline.entries(hours: hours, days: [], highlightFirst: true, current: snapshot.current)

        guard case .hour(let now, true) = entries.first, case .hour(let next, false) = entries[1] else {
            return XCTFail("Unexpected entries \(entries)")
        }
        XCTAssertEqual(now.temperatureCelsius, snapshot.current.temperatureCelsius)
        XCTAssertEqual(now.condition, snapshot.current.condition)
        XCTAssertEqual(now.date, hours[0].date)
        XCTAssertEqual(next, hours[1])
    }

    func testPluralForms() {
        XCTAssertEqual(WeatherFormatter.letters(2), "2 буквы")
        XCTAssertEqual(WeatherFormatter.letters(5), "5 букв")
        XCTAssertEqual(WeatherFormatter.days(1), "1 день")
        XCTAssertEqual(WeatherFormatter.days(10), "10 дней")
        XCTAssertEqual(WeatherFormatter.days(22), "22 дня")
    }

    func testEveryErrorHasUserFacingText() {
        let all: [RepositoryError] = [.offline, .timedOut, .serviceUnavailable, .rateLimited, .requestRejected, .invalidData, .unknown]
        for error in all {
            XCTAssertFalse(error.title.isEmpty)
            XCTAssertFalse(error.message.isEmpty)
            XCTAssertFalse(error.bannerText.isEmpty)
        }
        XCTAssertFalse(RepositoryError.requestRejected.isRetryable)
        XCTAssertTrue(RepositoryError.offline.isRetryable)
    }
}
