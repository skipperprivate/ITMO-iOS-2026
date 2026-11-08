//
//  CityPreviewViewModel.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

@Observable
@MainActor
final class CityPreviewViewModel {
    let detail: CityDetailViewModel
    private(set) var isFavorite = false
    private(set) var isUpdatingFavorite = false
    private let favoritesRepository: FavoritesRepositoryProtocol

    init(city: City, weatherRepository: WeatherRepositoryProtocol, favoritesRepository: FavoritesRepositoryProtocol) {
        self.detail = CityDetailViewModel(city: city, weatherRepository: weatherRepository)
        self.favoritesRepository = favoritesRepository
    }

    var city: City { detail.city }

    func loadFavoriteState() async {
        guard let favorites = try? await favoritesRepository.loadFavorites() else { return }
        isFavorite = favorites.contains { $0.id == city.id }
    }

    // Guarded so a double tap can't add and remove in the same moment.
    func toggleFavorite() async {
        guard !isUpdatingFavorite else { return }
        isUpdatingFavorite = true
        defer { isUpdatingFavorite = false }
        do {
            if isFavorite {
                try await favoritesRepository.removeFavorite(city)
            } else {
                try await favoritesRepository.addFavorite(city)
            }
            isFavorite.toggle()
        } catch {
            // The star keeps its old state, which still matches storage.
        }
    }
}
