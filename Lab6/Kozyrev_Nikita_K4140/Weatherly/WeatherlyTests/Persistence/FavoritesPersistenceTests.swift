//
//  FavoritesPersistenceTests.swift
//  WeatherlyTests
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation
import SwiftData
import XCTest
@testable import Weatherly

final class FavoritesPersistenceTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appending(path: "FavoritesTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private var storeURL: URL {
        directory.appending(path: "Favorites.store")
    }

    // A new container on the same file is what the next launch of the app sees.
    private func relaunch(defaultCities: [City] = [TestCities.moscow, TestCities.kazan]) -> SwiftDataFavoritesRepository {
        SwiftDataFavoritesRepository(
            container: PersistenceStack.favoritesContainer(at: storeURL),
            defaultCities: defaultCities
        )
    }

    private func city(_ index: Int) -> City {
        City(id: "test-\(index)", name: "Город \(index)", region: "", country: "Россия",
             latitude: 50, longitude: Double(index) / 10, timeZoneIdentifier: "Europe/Moscow")
    }

    // MARK: Seeding

    func testFirstLaunchSeedsDefaultCitiesInOrder() async throws {
        let favorites = try await relaunch().loadFavorites()

        XCTAssertEqual(favorites, [TestCities.moscow, TestCities.kazan])
    }

    func testDefaultsDoNotComeBackAfterUserRemovedEverything() async throws {
        let repository = relaunch()
        try await repository.removeFavorite(id: TestCities.moscow.id)
        try await repository.removeFavorite(id: TestCities.kazan.id)

        let favorites = try await relaunch().loadFavorites()

        XCTAssertEqual(favorites, [])
    }

    func testFirstCallBeingAnAddStillSeedsFirst() async throws {
        try await relaunch().addFavorite(TestCities.sochi)

        let favorites = try await relaunch().loadFavorites()

        XCTAssertEqual(favorites, [TestCities.moscow, TestCities.kazan, TestCities.sochi])
    }

    // MARK: Changes survive a relaunch

    func testAddedCitySurvivesRelaunch() async throws {
        try await relaunch().addFavorite(TestCities.sochi)

        let favorites = try await relaunch().loadFavorites()

        XCTAssertEqual(favorites.last, TestCities.sochi)
    }

    func testReorderSurvivesRelaunch() async throws {
        let repository = relaunch()
        try await repository.addFavorite(TestCities.sochi)
        try await repository.reorderFavorites([TestCities.sochi.id, TestCities.moscow.id, TestCities.kazan.id])

        let favorites = try await relaunch().loadFavorites()

        XCTAssertEqual(favorites, [TestCities.sochi, TestCities.moscow, TestCities.kazan])
    }

    func testRemovalKeepsOrderOfTheRest() async throws {
        let repository = relaunch()
        try await repository.addFavorite(TestCities.sochi)
        try await repository.removeFavorite(id: TestCities.kazan.id)
        try await repository.addFavorite(city(1))

        let favorites = try await relaunch().loadFavorites()

        XCTAssertEqual(favorites, [TestCities.moscow, TestCities.sochi, city(1)])
    }

    // MARK: Contract details

    func testAddingSavedCityUpdatesItInPlaceWithoutDuplicate() async throws {
        let repository = relaunch()
        let renamed = City(id: TestCities.moscow.id, name: "Москва (обновлено)", region: "", country: "Россия",
                           latitude: TestCities.moscow.latitude, longitude: TestCities.moscow.longitude,
                           timeZoneIdentifier: TestCities.moscow.timeZoneIdentifier)

        try await repository.addFavorite(renamed)

        let favorites = try await repository.loadFavorites()
        XCTAssertEqual(favorites, [renamed, TestCities.kazan])
    }

    func testReorderKeepsCitiesTheCallerDidNotKnowAbout() async throws {
        let repository = relaunch()
        try await repository.addFavorite(TestCities.sochi)

        // The screen still shows only the first two cities and also sends an id that is gone.
        try await repository.reorderFavorites([TestCities.kazan.id, "removed", TestCities.moscow.id, TestCities.kazan.id])

        let favorites = try await repository.loadFavorites()
        XCTAssertEqual(favorites, [TestCities.kazan, TestCities.moscow, TestCities.sochi])
    }

    func testRemovingUnknownCityIsNoOp() async throws {
        let repository = relaunch()

        try await repository.removeFavorite(id: "unknown")

        let favorites = try await repository.loadFavorites()
        XCTAssertEqual(favorites, [TestCities.moscow, TestCities.kazan])
    }

    func testAddBeyondLimitFailsAndChangesNothing() async throws {
        let repository = relaunch(defaultCities: (0..<FavoritesPolicy.maximumCount).map(city))

        do {
            try await repository.addFavorite(TestCities.sochi)
            XCTFail("Expected the limit error")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .favoritesLimitReached)
        }

        let favorites = try await relaunch().loadFavorites()
        XCTAssertEqual(favorites.count, FavoritesPolicy.maximumCount)
        XCTAssertFalse(favorites.contains(TestCities.sochi))
    }

    func testUpdatingSavedCityIsAllowedAtLimit() async throws {
        let cities = (0..<FavoritesPolicy.maximumCount).map(city)
        let repository = relaunch(defaultCities: cities)

        try await repository.addFavorite(cities[0])

        let favorites = try await repository.loadFavorites()
        XCTAssertEqual(favorites, cities)
    }

    func testConcurrentAddsDoNotDuplicateCitiesOrSeedTwice() async throws {
        let repository = relaunch()
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<20 {
                group.addTask { try await repository.addFavorite(TestCities.sochi) }
            }
            try await group.waitForAll()
        }

        let favorites = try await relaunch().loadFavorites()
        XCTAssertEqual(favorites, [TestCities.moscow, TestCities.kazan, TestCities.sochi])
    }

    // MARK: Infrastructure

    func testStoreWorksOffTheMainThread() async {
        let repository = relaunch()

        let isOnMain = await repository.store.value.isRunningOnMainThread()

        XCTAssertFalse(isOnMain)
    }

    func testUnreadableStoreIsMovedAsideAndReplaced() async throws {
        try Data("definitely not sqlite".utf8).write(to: storeURL)

        let favorites = try await relaunch().loadFavorites()

        XCTAssertEqual(favorites, [TestCities.moscow, TestCities.kazan])
        let files = try FileManager.default.contentsOfDirectory(atPath: directory.path())
        XCTAssertTrue(files.contains { $0.hasPrefix("Favorites-corrupt-") }, "Damaged file is kept for diagnostics: \(files)")
    }

    func testInMemoryContainerStartsEmptyAndSeeds() async throws {
        let repository = SwiftDataFavoritesRepository(
            container: PersistenceStack.inMemoryFavoritesContainer(),
            defaultCities: [TestCities.sochi]
        )

        let favorites = try await repository.loadFavorites()

        XCTAssertEqual(favorites, [TestCities.sochi])
    }
}

extension FavoritesStore {
    func isRunningOnMainThread() -> Bool {
        pthread_main_np() != 0
    }
}
