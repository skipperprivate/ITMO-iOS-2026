//
//  InMemoryFavoritesRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

#if DEBUG
import Foundation

// Previews and tests; same contract as SwiftDataFavoritesRepository, nothing persisted.
actor InMemoryFavoritesRepository: FavoritesRepositoryProtocol {
    private var cities: [City]

    init(initialCities: [City] = DefaultCities.all) {
        self.cities = initialCities
    }

    func loadFavorites() async throws -> [City] {
        cities
    }

    func addFavorite(_ city: City) async throws {
        if let index = cities.firstIndex(where: { $0.id == city.id }) {
            cities[index] = city
            return
        }
        guard cities.count < FavoritesPolicy.maximumCount else { throw RepositoryError.favoritesLimitReached }
        cities.append(city)
    }

    func removeFavorite(id: City.ID) async throws {
        cities.removeAll { $0.id == id }
    }

    func reorderFavorites(_ ids: [City.ID]) async throws {
        var seen = Set<City.ID>()
        let listed = ids.filter { seen.insert($0).inserted }.compactMap { id in cities.first { $0.id == id } }
        cities = listed + cities.filter { !seen.contains($0.id) }
    }
}
#endif
