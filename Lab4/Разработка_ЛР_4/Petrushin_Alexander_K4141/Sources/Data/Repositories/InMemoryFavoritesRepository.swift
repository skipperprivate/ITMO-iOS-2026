//
//  InMemoryFavoritesRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// Stage 2 replaces this with a SwiftData @ModelActor of the same shape.
actor InMemoryFavoritesRepository: FavoritesRepositoryProtocol {
    private var cities: [City]

    init(initialCities: [City] = DefaultCities.all) {
        self.cities = initialCities
    }

    func loadFavorites() async throws -> [City] {
        cities
    }

    func addFavorite(_ city: City) async throws {
        guard !cities.contains(where: { $0.id == city.id }) else { return }
        cities.append(city)
    }

    func removeFavorite(_ city: City) async throws {
        cities.removeAll { $0.id == city.id }
    }

    func moveFavorite(from source: IndexSet, to destination: Int) async throws {
        let itemsToMove = source.map { cities[$0] }
        for index in source.sorted(by: >) {
            cities.remove(at: index)
        }
        let removedBeforeDestination = source.filter { $0 < destination }.count
        let adjustedDestination = max(0, min(destination - removedBeforeDestination, cities.count))
        cities.insert(contentsOf: itemsToMove, at: adjustedDestination)
    }
}
