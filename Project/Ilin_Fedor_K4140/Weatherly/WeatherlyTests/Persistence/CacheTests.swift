//
//  CacheTests.swift
//  WeatherlyTests
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation
import SwiftData
import XCTest
@testable import Weatherly

final class TestClock: @unchecked Sendable {
    private let lock = NSLock()
    private var current = Date(timeIntervalSince1970: 1_790_700_000)

    var now: Date {
        get { lock.withLock { current } }
        set { lock.withLock { current = newValue } }
    }

    func advance(by interval: TimeInterval) {
        lock.withLock { current += interval }
    }
}

final class CachingWeatherRepositoryTests: XCTestCase {
    private let clock = TestClock()
    private var upstream: StubWeatherRepository!
    private var repository: CachingWeatherRepository!

    override func setUp() {
        let clock = clock
        upstream = StubWeatherRepository { MockData.snapshot(for: $0, now: clock.now) }
        repository = makeRepository(container: PersistenceStack.inMemoryCacheContainer())
    }

    private func makeRepository(container: ModelContainer) -> CachingWeatherRepository {
        let clock = clock
        return CachingWeatherRepository(upstream: upstream, cache: CacheStoreHandle(container: container), now: { clock.now })
    }

    func testFreshCacheAnswersWithoutRequest() async throws {
        _ = try await repository.snapshot(for: TestCities.moscow)
        clock.advance(by: ForecastFreshness.freshInterval - 1)

        let snapshot = try await repository.snapshot(for: TestCities.moscow)

        XCTAssertEqual(upstream.callCount, 1)
        XCTAssertEqual(snapshot.city, TestCities.moscow)
    }

    func testStaleCacheIsRefetchedAndOverwritten() async throws {
        _ = try await repository.snapshot(for: TestCities.moscow)
        clock.advance(by: ForecastFreshness.freshInterval + 1)

        let snapshot = try await repository.snapshot(for: TestCities.moscow)

        XCTAssertEqual(upstream.callCount, 2)
        XCTAssertEqual(snapshot.fetchedAt, clock.now)
        let cached = await repository.cachedSnapshot(for: TestCities.moscow)
        XCTAssertEqual(cached?.fetchedAt, clock.now)
    }

    func testReloadIgnoringCacheAlwaysAsks() async throws {
        _ = try await repository.snapshot(for: TestCities.moscow)

        _ = try await repository.snapshot(for: TestCities.moscow, policy: .reloadIgnoringCache)

        XCTAssertEqual(upstream.callCount, 2)
    }

    func testFailedRefreshThrowsAndStoredDataStaysAvailable() async throws {
        let first = try await repository.snapshot(for: TestCities.moscow)
        clock.advance(by: 3600)
        upstream.respond { _ in throw RepositoryError.offline }

        do {
            _ = try await repository.snapshot(for: TestCities.moscow)
            XCTFail("A stale record must not hide the failure from the caller")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .offline)
        }
        let cached = await repository.cachedSnapshot(for: TestCities.moscow)
        XCTAssertEqual(cached?.fetchedAt, first.fetchedAt)
    }

    func testDataOlderThanDisplayAgeIsNotOffered() async throws {
        _ = try await repository.snapshot(for: TestCities.moscow)

        clock.advance(by: ForecastFreshness.maximumDisplayAge - 60)
        let stillShown = await repository.cachedSnapshot(for: TestCities.moscow)
        clock.advance(by: 120)
        let tooOld = await repository.cachedSnapshot(for: TestCities.moscow)

        XCTAssertNotNil(stillShown)
        XCTAssertNil(tooOld)
    }

    // The clock was moved back: the record looks like it's from the future.
    func testFutureTimestampIsStaleButStillShown() async throws {
        _ = try await repository.snapshot(for: TestCities.moscow)
        clock.advance(by: -3600)

        let cached = await repository.cachedSnapshot(for: TestCities.moscow)
        _ = try await repository.snapshot(for: TestCities.moscow)

        XCTAssertNotNil(cached)
        XCTAssertEqual(upstream.callCount, 2)
    }

    func testSameLocationUnderAnotherCityComesBackAsTheRequestedCity() async throws {
        _ = try await repository.snapshot(for: TestCities.moscow)
        let sameSpot = City(id: "custom", name: "Красная площадь", region: "", country: "Россия",
                            latitude: TestCities.moscow.latitude, longitude: TestCities.moscow.longitude,
                            timeZoneIdentifier: TestCities.moscow.timeZoneIdentifier)

        let snapshot = try await repository.snapshot(for: sameSpot)

        XCTAssertEqual(upstream.callCount, 1)
        XCTAssertEqual(snapshot.city, sameSpot)
    }

    func testCacheSurvivesRelaunch() async throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "Cache-\(UUID().uuidString).store")
        defer { try? FileManager.default.removeItem(at: url) }
        _ = try await makeRepository(container: PersistenceStack.cacheContainer(at: url)).snapshot(for: TestCities.kazan)

        let relaunched = makeRepository(container: PersistenceStack.cacheContainer(at: url))
        let cached = await relaunched.cachedSnapshot(for: TestCities.kazan)

        XCTAssertEqual(cached?.city, TestCities.kazan)
        XCTAssertEqual(cached?.fetchedAt, clock.now)
    }

    func testRecordOfOlderPayloadVersionIsAMissAndIsDropped() async throws {
        let container = PersistenceStack.inMemoryCacheContainer()
        let context = ModelContext(container)
        context.insert(CachedForecastRecord(
            key: CachingWeatherRepository.key(for: TestCities.moscow),
            fetchedAt: clock.now,
            payloadVersion: CacheLimits.payloadVersion - 1,
            payload: Data("{\"old\":true}".utf8)
        ))
        try context.save()
        let repository = makeRepository(container: container)

        let cached = await repository.cachedSnapshot(for: TestCities.moscow)

        XCTAssertNil(cached)
        XCTAssertEqual(try ModelContext(container).fetchCount(FetchDescriptor<CachedForecastRecord>()), 0)
    }
}

final class CacheStoreTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_790_700_000)

    private func forecast(_ index: Int, age: TimeInterval) -> (CityWeatherSnapshot, String) {
        let city = City(id: "c\(index)", name: "Город \(index)", region: "", country: "", latitude: 50,
                        longitude: Double(index) / 100, timeZoneIdentifier: "Europe/Moscow")
        return (MockData.snapshot(for: city, now: now - age), CachingWeatherRepository.key(for: city))
    }

    func testPurgeDropsOldRecordsAndKeepsNewestWithinLimit() async throws {
        let container = PersistenceStack.inMemoryCacheContainer()
        let store = await CacheStoreHandle(container: container).store.value
        for index in 0..<(CacheLimits.maximumForecasts + 5) {
            let (snapshot, key) = forecast(index, age: TimeInterval(index) * 60)
            try await store.saveForecast(snapshot, forKey: key)
        }
        let (expired, expiredKey) = forecast(999, age: CacheLimits.forecastRetention + 60)
        try await store.saveForecast(expired, forKey: expiredKey)

        try await store.purge(now: now)

        let newest = try await store.forecast(forKey: forecast(0, age: 0).1)
        let beyondLimit = try await store.forecast(forKey: forecast(CacheLimits.maximumForecasts, age: 0).1)
        let tooOld = try await store.forecast(forKey: expiredKey)
        XCTAssertNotNil(newest)
        XCTAssertNil(beyondLimit)
        XCTAssertNil(tooOld)
        XCTAssertEqual(try ModelContext(container).fetchCount(FetchDescriptor<CachedForecastRecord>()), CacheLimits.maximumForecasts)
    }

    func testPurgeDropsEmptySearchesSoonerThanFoundOnes() async throws {
        let store = await CacheStoreHandle(container: PersistenceStack.inMemoryCacheContainer()).store.value
        let twoDaysAgo = now - 2 * 24 * 3600
        try await store.saveSearchResults([], forQuery: "абвгд", fetchedAt: twoDaysAgo)
        try await store.saveSearchResults([TestCities.kazan], forQuery: "казань", fetchedAt: twoDaysAgo)
        try await store.saveSearchResults([TestCities.sochi], forQuery: "сочи", fetchedAt: now - CacheLimits.searchRetention - 60)

        try await store.purge(now: now)

        let empty = try await store.searchResults(forQuery: "абвгд")
        let found = try await store.searchResults(forQuery: "казань")
        let ancient = try await store.searchResults(forQuery: "сочи")
        XCTAssertNil(empty)
        XCTAssertEqual(found?.cities, [TestCities.kazan])
        XCTAssertNil(ancient)
    }

    func testStoreWorksOffTheMainThread() async {
        let store = await CacheStoreHandle(container: PersistenceStack.inMemoryCacheContainer()).store.value

        let isOnMain = await store.isRunningOnMainThread()

        XCTAssertFalse(isOnMain)
    }

    func testUnreadableStoreIsRecreatedEmpty() async throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "Cache-\(UUID().uuidString).store")
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("definitely not sqlite".utf8).write(to: url)

        let store = await CacheStoreHandle(container: PersistenceStack.cacheContainer(at: url)).store.value
        let (snapshot, key) = forecast(1, age: 0)
        try await store.saveForecast(snapshot, forKey: key)

        let restored = try await store.forecast(forKey: key)
        XCTAssertEqual(restored?.city, snapshot.city)
    }
}

final class CachingGeocodingRepositoryTests: XCTestCase {
    private let clock = TestClock()
    private var upstream: StubGeocodingRepository!
    private var repository: CachingGeocodingRepository!

    override func setUp() {
        let clock = clock
        upstream = StubGeocodingRepository(result: .success([TestCities.kazan]))
        repository = CachingGeocodingRepository(
            upstream: upstream,
            cache: CacheStoreHandle(container: PersistenceStack.inMemoryCacheContainer()),
            now: { clock.now }
        )
    }

    func testRepeatedQueryIsAnsweredFromCacheIgnoringCaseAndSpaces() async throws {
        _ = try await repository.searchCities(matching: "Казань")

        let cities = try await repository.searchCities(matching: "  КАЗАНЬ ")

        XCTAssertEqual(cities, [TestCities.kazan])
        XCTAssertEqual(upstream.receivedQueries, ["Казань"])
    }

    func testFoundListStaysFreshForAWeek() async throws {
        _ = try await repository.searchCities(matching: "казань")

        clock.advance(by: CacheLimits.searchFreshInterval - 60)
        _ = try await repository.searchCities(matching: "казань")
        clock.advance(by: 120)
        _ = try await repository.searchCities(matching: "казань")

        XCTAssertEqual(upstream.receivedQueries.count, 2)
    }

    func testNothingFoundIsAskedAgainNextDay() async throws {
        upstream.respond(with: .success([]))
        _ = try await repository.searchCities(matching: "абвгд")

        clock.advance(by: 3600)
        _ = try await repository.searchCities(matching: "абвгд")
        clock.advance(by: CacheLimits.emptySearchFreshInterval)
        _ = try await repository.searchCities(matching: "абвгд")

        XCTAssertEqual(upstream.receivedQueries.count, 2)
    }

    func testOfflineFallsBackToOutdatedList() async throws {
        _ = try await repository.searchCities(matching: "казань")
        clock.advance(by: CacheLimits.searchFreshInterval + 60)
        upstream.respond(with: .failure(.offline))

        let cities = try await repository.searchCities(matching: "казань")

        XCTAssertEqual(cities, [TestCities.kazan])
    }

    func testOfflineWithoutCacheFails() async {
        upstream.respond(with: .failure(.offline))

        do {
            _ = try await repository.searchCities(matching: "казань")
            XCTFail("Expected the offline error")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .offline)
        }
    }

    func testFailuresAreNotCached() async throws {
        upstream.respond(with: .failure(.serviceUnavailable))
        _ = try? await repository.searchCities(matching: "казань")
        upstream.respond(with: .success([TestCities.kazan]))

        let cities = try await repository.searchCities(matching: "казань")

        XCTAssertEqual(cities, [TestCities.kazan])
        XCTAssertEqual(upstream.receivedQueries.count, 2)
    }
}

extension CacheStore {
    func isRunningOnMainThread() -> Bool {
        pthread_main_np() != 0
    }
}
