//
//  FavoritesRepositoryProtocol.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

nonisolated enum FavoritesPolicy {
    // Places loads every favourite at once; more would run into Open-Meteo's rate limits.
    static let maximumCount = 20
}

// Errors are RepositoryError (.storageFailed, .favoritesLimitReached).
// Everything is addressed by city id, never by list index: the screen's list may be behind storage.
nonisolated protocol FavoritesRepositoryProtocol: Sendable {
    func loadFavorites() async throws -> [City]
    // Appends a new city; for one already saved, refreshes its fields and keeps its position.
    func addFavorite(_ city: City) async throws
    func removeFavorite(id: City.ID) async throws
    // Saved cities missing from `ids` (added meanwhile elsewhere) keep their order after the listed ones.
    func reorderFavorites(_ ids: [City.ID]) async throws
}
