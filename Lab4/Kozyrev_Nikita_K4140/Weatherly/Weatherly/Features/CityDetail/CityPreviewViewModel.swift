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
    // Shown briefly over the forecast; the star keeps its old state, which still matches storage.
    private(set) var favoriteError: RepositoryError?
    private let favoritesRepository: FavoritesRepositoryProtocol
    @ObservationIgnored private var errorDismissal: Task<Void, Never>?

    static let errorDisplayNanoseconds: UInt64 = 3_000_000_000

    init(city: City, weatherRepository: WeatherRepositoryProtocol, favoritesRepository: FavoritesRepositoryProtocol) {
        self.detail = CityDetailViewModel(city: city, weatherRepository: weatherRepository)
        self.favoritesRepository = favoritesRepository
    }

    var city: City { detail.city }

    func loadFavoriteState() async {
        do {
            let favorites = try await favoritesRepository.loadFavorites()
            isFavorite = favorites.contains { $0.id == city.id }
            showError(nil)
        } catch {
            showError(RepositoryError.from(error))
        }
    }

    // Guarded so a double tap can't add and remove in the same moment.
    func toggleFavorite() async {
        guard !isUpdatingFavorite else { return }
        isUpdatingFavorite = true
        defer { isUpdatingFavorite = false }
        do {
            if isFavorite {
                try await favoritesRepository.removeFavorite(id: city.id)
            } else {
                try await favoritesRepository.addFavorite(city)
            }
            isFavorite.toggle()
            showError(nil)
        } catch {
            showError(RepositoryError.from(error))
        }
    }

    private func showError(_ error: RepositoryError?) {
        errorDismissal?.cancel()
        favoriteError = error
        guard error != nil else { return }
        errorDismissal = Task { [weak self] in
            try? await Task.sleep(nanoseconds: Self.errorDisplayNanoseconds)
            guard !Task.isCancelled else { return }
            self?.favoriteError = nil
        }
    }
}
