//
//  SwiftDataFavoritesRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation
import OSLog
import SwiftData

// Favourites persisted with SwiftData; DefaultCities go in on the very first launch only.
nonisolated final class SwiftDataFavoritesRepository: FavoritesRepositoryProtocol, Sendable {
    // Created in a detached task: a @ModelActor made on the main thread binds its context
    // to the main queue and would run every fetch and save there.
    let store: Task<FavoritesStore, Never>

    private let defaultCities: [City]
    private let now: @Sendable () -> Date
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Weatherly", category: "Persistence")

    init(
        container: ModelContainer,
        defaultCities: [City] = DefaultCities.all,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        store = Task.detached { FavoritesStore(modelContainer: container) }
        self.defaultCities = defaultCities
        self.now = now
    }

    func loadFavorites() async throws -> [City] {
        try await perform { try await $0.favorites() }
    }

    func addFavorite(_ city: City) async throws {
        let now = now()
        try await perform { try await $0.add(city, limit: FavoritesPolicy.maximumCount, now: now) }
    }

    func removeFavorite(id: City.ID) async throws {
        try await perform { try await $0.remove(id: id) }
    }

    func reorderFavorites(_ ids: [City.ID]) async throws {
        try await perform { try await $0.reorder(ids) }
    }

    // SwiftData errors don't leave the Data layer; the UI only needs to know saving failed.
    private func perform<Value: Sendable>(_ operation: (FavoritesStore) async throws -> Value) async throws -> Value {
        let store = await store.value
        do {
            try await store.seedIfNeeded(with: defaultCities, now: now())
            return try await operation(store)
        } catch let error as RepositoryError {
            throw error
        } catch {
            logger.error("Favorites storage failed: \(error.localizedDescription, privacy: .public)")
            throw RepositoryError.storageFailed
        }
    }
}
