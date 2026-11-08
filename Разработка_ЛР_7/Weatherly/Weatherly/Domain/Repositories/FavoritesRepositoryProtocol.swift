//
//  FavoritesRepositoryProtocol.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

nonisolated protocol FavoritesRepositoryProtocol: Sendable {
    func loadFavorites() async throws -> [City]
    func addFavorite(_ city: City) async throws
    func removeFavorite(_ city: City) async throws
    func moveFavorite(from source: IndexSet, to destination: Int) async throws
}
