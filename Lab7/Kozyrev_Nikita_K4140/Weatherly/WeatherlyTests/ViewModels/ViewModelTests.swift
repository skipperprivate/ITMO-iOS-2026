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
        let repository = StubWeatherRepository { MockData.snapshot(for: $0, now: clock.now) }
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: repository, now: { clock.now })

        await viewModel.loadIfNeeded()
        clock.now += ForecastFreshness.freshInterval - 1
        await viewModel.loadIfNeeded()
        XCTAssertEqual(repository.callCount, 1)

        clock.now += 2
        await viewModel.loadIfNeeded()
        XCTAssertEqual(repository.callCount, 2)
    }

    func testStoredDataIsShownAtOnceWhenNetworkFails() async {
        let clock = Clock()
        let repository = StubWeatherRepository { _ in throw RepositoryError.offline }
        let stored = MockData.snapshot(for: TestCities.moscow, now: clock.now - 3 * 3600)
        repository.store(stored)
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: repository, now: { clock.now })

        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.snapshot, stored)
        XCTAssertEqual(viewModel.lastUpdated, stored.fetchedAt, "The footer shows the data's age, not the moment it was shown")
        XCTAssertEqual(viewModel.refreshError, .offline)
        XCTAssertEqual(repository.callCount, 1)
    }

    func testFreshStoredDataNeedsNoRequest() async {
        let clock = Clock()
        let repository = StubWeatherRepository()
        repository.store(MockData.snapshot(for: TestCities.moscow, now: clock.now - 60))
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: repository, now: { clock.now })

        await viewModel.loadIfNeeded()

        XCTAssertNotNil(viewModel.snapshot)
        XCTAssertEqual(repository.callCount, 0)
    }

    func testStaleStoredDataIsReplacedByNetworkData() async {
        let clock = Clock()
        let repository = StubWeatherRepository { MockData.snapshot(for: $0, now: clock.now) }
        repository.store(MockData.snapshot(for: TestCities.moscow, now: clock.now - 3600))
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: repository, now: { clock.now })

        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.lastUpdated, clock.now)
        XCTAssertNil(viewModel.refreshError)
        XCTAssertEqual(repository.requestedPolicies, [.returnFreshCache])
    }

    func testPullToRefreshBypassesCache() async {
        let repository = StubWeatherRepository()
        let viewModel = CityDetailViewModel(city: TestCities.moscow, weatherRepository: repository)

        await viewModel.refresh()

        XCTAssertEqual(repository.requestedPolicies, [.reloadIgnoringCache])
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
    func testFailedReloadKeepsCitiesAndWeatherAndShowsStorageError() async {
        let favorites = RecordingFavoritesRepository(cities: [TestCities.moscow])
        let viewModel = PlacesViewModel(favoritesRepository: favorites, weatherRepository: StubWeatherRepository())
        await viewModel.load()
        let weather = viewModel.weather
        await favorites.failLoading(with: .storageFailed)

        await viewModel.load()

        XCTAssertEqual(viewModel.cities, [TestCities.moscow])
        XCTAssertEqual(viewModel.weather, weather)
        XCTAssertEqual(viewModel.editError, .storageFailed)
        guard case .loaded = viewModel.state else { return XCTFail("Expected loaded state") }

        await favorites.failLoading(with: nil)
        await viewModel.load()
        XCTAssertNil(viewModel.editError)
    }

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

    func testCardsShowStoredWeatherWhenOffline() async {
        let weather = StubWeatherRepository { _ in throw RepositoryError.offline }
        let stored = MockData.snapshot(for: TestCities.kazan, now: Date() - 3600)
        weather.store(stored)
        let viewModel = makeViewModel(weather: weather)

        await viewModel.load()

        XCTAssertEqual(viewModel.weather(for: TestCities.kazan), .loaded(stored.current))
        XCTAssertEqual(viewModel.weather(for: TestCities.moscow), .unavailable)
        XCTAssertEqual(viewModel.weatherError, .offline)
    }

    func testPullToRefreshAsksServerForEveryCity() async {
        let weather = StubWeatherRepository()
        let viewModel = makeViewModel(weather: weather)
        await viewModel.load()

        await viewModel.refreshWeather(policy: .reloadIgnoringCache)

        XCTAssertEqual(Array(weather.requestedPolicies.suffix(3)), Array(repeating: .reloadIgnoringCache, count: 3))
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

    func testWritesReachStorageInTheOrderTheUserMadeThem() async {
        let favorites = RecordingFavoritesRepository(cities: [TestCities.moscow, TestCities.kazan, TestCities.sochi])
        // Without the write queue the later reorder would overtake this removal.
        await favorites.slowDownRemoval(by: 100_000_000)
        let viewModel = PlacesViewModel(favoritesRepository: favorites, weatherRepository: StubWeatherRepository())
        await viewModel.load()

        viewModel.remove(at: IndexSet(integer: 0))
        viewModel.move(from: IndexSet(integer: 1), to: 0)

        let settled = await eventually { await favorites.writes.count == 2 }
        XCTAssertTrue(settled)
        let writes = await favorites.writes
        let stored = await favorites.cities
        XCTAssertEqual(writes, ["remove \(TestCities.moscow.id)", "reorder"])
        XCTAssertEqual(stored, [TestCities.sochi, TestCities.kazan])
        XCTAssertEqual(viewModel.cities, stored)
    }

    func testFailedWriteRestoresListFromStorageAndShowsError() async {
        let favorites = RecordingFavoritesRepository(cities: [TestCities.moscow, TestCities.kazan])
        await favorites.fail(with: .storageFailed)
        let viewModel = PlacesViewModel(favoritesRepository: favorites, weatherRepository: StubWeatherRepository())
        await viewModel.load()

        viewModel.remove(at: IndexSet(integer: 0))
        XCTAssertEqual(viewModel.cities, [TestCities.kazan], "Removal shows up before storage confirms it")

        let failed = await eventually { viewModel.editError != nil }
        XCTAssertTrue(failed)
        XCTAssertEqual(viewModel.editError, .storageFailed)
        XCTAssertEqual(viewModel.cities, [TestCities.moscow, TestCities.kazan])
    }

    func testLoadWaitsForQueuedWritesAndClearsEditError() async {
        let favorites = RecordingFavoritesRepository(cities: [TestCities.moscow, TestCities.kazan])
        await favorites.slowDownRemoval(by: 100_000_000)
        let viewModel = PlacesViewModel(favoritesRepository: favorites, weatherRepository: StubWeatherRepository())
        await viewModel.load()

        viewModel.remove(at: IndexSet(integer: 0))
        await viewModel.load()

        XCTAssertEqual(viewModel.cities, [TestCities.kazan], "A reload must not bring the removed city back")
        XCTAssertNil(viewModel.editError)
    }

    private func waitForFavorites(_ repository: InMemoryFavoritesRepository, _ condition: @escaping ([City]) -> Bool) async -> Bool {
        await eventually {
            guard let cities = try? await repository.loadFavorites() else { return false }
            return condition(cities)
        }
    }
}

@MainActor
final class HomeViewModelTests: XCTestCase {
    private func makeViewModel(
        cities: [City] = [TestCities.moscow, TestCities.kazan],
        appState: StubAppStateRepository
    ) -> HomeViewModel {
        HomeViewModel(
            favoritesRepository: InMemoryFavoritesRepository(initialCities: cities),
            weatherRepository: StubWeatherRepository(),
            appStateRepository: appState
        )
    }

    func testOpensOnThePageItWasLeftOn() async {
        let viewModel = makeViewModel(appState: StubAppStateRepository(selectedCityID: TestCities.kazan.id))

        await viewModel.loadFavorites()

        XCTAssertEqual(viewModel.selectedCity, TestCities.kazan)
    }

    func testFallsBackToFirstCityWhenSavedOneWasRemoved() async {
        let appState = StubAppStateRepository(selectedCityID: TestCities.sochi.id)
        let viewModel = makeViewModel(appState: appState)

        await viewModel.loadFavorites()

        XCTAssertEqual(viewModel.selectedCity, TestCities.moscow)
        XCTAssertEqual(appState.loadSelectedCityID(), TestCities.moscow.id)
    }

    func testSavedPageSurvivesPagerReportingFirstPage() async {
        let appState = StubAppStateRepository(selectedCityID: TestCities.kazan.id)
        let viewModel = makeViewModel(appState: appState)
        await viewModel.loadFavorites()

        // What a paged TabView does while laying out on launch.
        viewModel.selectedCityID = TestCities.moscow.id
        await viewModel.pagerDidAppear()

        XCTAssertEqual(viewModel.selectedCity, TestCities.kazan)
        XCTAssertEqual(appState.loadSelectedCityID(), TestCities.kazan.id)
    }

    func testPagerAppearingAgainDoesNotUndoUserSwipe() async {
        let viewModel = makeViewModel(appState: StubAppStateRepository(selectedCityID: TestCities.kazan.id))
        await viewModel.loadFavorites()
        await viewModel.pagerDidAppear()

        viewModel.selectedCityID = TestCities.moscow.id
        await viewModel.pagerDidAppear()

        XCTAssertEqual(viewModel.selectedCity, TestCities.moscow)
    }

    func testSelectionIsSaved() async {
        let appState = StubAppStateRepository()
        let viewModel = makeViewModel(appState: appState)
        await viewModel.loadFavorites()

        viewModel.select(TestCities.kazan)

        XCTAssertEqual(appState.loadSelectedCityID(), TestCities.kazan.id)
    }
}

@MainActor
final class CityPreviewViewModelTests: XCTestCase {
    func testFailedFavoriteReadKeepsStarAndShowsErrorUntilSuccessfulReload() async {
        let favorites = RecordingFavoritesRepository(cities: [TestCities.moscow])
        let viewModel = CityPreviewViewModel(city: TestCities.moscow, weatherRepository: StubWeatherRepository(), favoritesRepository: favorites)
        await viewModel.loadFavoriteState()
        await favorites.failLoading(with: .storageFailed)

        await viewModel.loadFavoriteState()

        XCTAssertTrue(viewModel.isFavorite)
        XCTAssertEqual(viewModel.favoriteError, .storageFailed)

        await favorites.failLoading(with: nil)
        await viewModel.loadFavoriteState()
        XCTAssertTrue(viewModel.isFavorite)
        XCTAssertNil(viewModel.favoriteError)
    }

    func testStarTogglesAndStorageFollows() async {
        let favorites = RecordingFavoritesRepository(cities: [TestCities.moscow])
        let viewModel = CityPreviewViewModel(city: TestCities.sochi, weatherRepository: StubWeatherRepository(), favoritesRepository: favorites)
        await viewModel.loadFavoriteState()
        XCTAssertFalse(viewModel.isFavorite)

        await viewModel.toggleFavorite()
        XCTAssertTrue(viewModel.isFavorite)
        await viewModel.toggleFavorite()

        XCTAssertFalse(viewModel.isFavorite)
        let writes = await favorites.writes
        XCTAssertEqual(writes, ["add \(TestCities.sochi.id)", "remove \(TestCities.sochi.id)"])
        XCTAssertNil(viewModel.favoriteError)
    }

    func testLimitErrorIsShownAndStarKeepsItsState() async {
        let favorites = RecordingFavoritesRepository(cities: [TestCities.moscow])
        await favorites.fail(with: .favoritesLimitReached)
        let viewModel = CityPreviewViewModel(city: TestCities.sochi, weatherRepository: StubWeatherRepository(), favoritesRepository: favorites)

        await viewModel.toggleFavorite()

        XCTAssertFalse(viewModel.isFavorite)
        XCTAssertEqual(viewModel.favoriteError, .favoritesLimitReached)
        XCTAssertFalse(viewModel.isUpdatingFavorite)
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
        XCTAssertEqual(WeatherFormatter.updated(at: now - 30 * 3600, now: now), "Обновлено 1 день назад")
        XCTAssertEqual(WeatherFormatter.updated(at: now - 50 * 3600, now: now), "Обновлено 2 дня назад")
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
        let all: [RepositoryError] = [.offline, .timedOut, .serviceUnavailable, .rateLimited, .requestRejected, .invalidData, .storageFailed, .favoritesLimitReached, .unknown]
        for error in all {
            XCTAssertFalse(error.title.isEmpty)
            XCTAssertFalse(error.message.isEmpty)
            XCTAssertFalse(error.bannerText.isEmpty)
        }
        XCTAssertFalse(RepositoryError.requestRejected.isRetryable)
        XCTAssertTrue(RepositoryError.offline.isRetryable)
        XCTAssertFalse(RepositoryError.favoritesLimitReached.isRetryable, "Retrying cannot free a slot")
    }
}
