//
//  HomeViewModel.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

@Observable
@MainActor
final class HomeViewModel {
    enum State {
        case loading
        case loaded
        case failed(RepositoryError)
    }

    private(set) var state: State = .loading
    private(set) var favoriteCities: [City] = []
    var selectedCityID: String?

    private let favoritesRepository: FavoritesRepositoryProtocol
    private let weatherRepository: WeatherRepositoryProtocol
    // Mutated during view building, so it must not trigger observation.
    @ObservationIgnored private var detailViewModels: [String: CityDetailViewModel] = [:]

    init(favoritesRepository: FavoritesRepositoryProtocol, weatherRepository: WeatherRepositoryProtocol) {
        self.favoritesRepository = favoritesRepository
        self.weatherRepository = weatherRepository
    }

    var selectedCity: City? {
        favoriteCities.first { $0.id == selectedCityID }
    }

    var selectedSnapshot: CityWeatherSnapshot? {
        selectedCity.flatMap { detailViewModels[$0.id]?.snapshot }
    }

    func loadFavorites() async {
        let isFirstLoad = favoriteCities.isEmpty
        if isFirstLoad { state = .loading }
        do {
            let cities = try await favoritesRepository.loadFavorites()
            // Pages of removed cities are dropped, kept ones keep their loaded weather.
            let ids = Set(cities.map(\.id))
            detailViewModels = detailViewModels.filter { ids.contains($0.key) }
            favoriteCities = cities
            if !(selectedCityID.map { ids.contains($0) } ?? false) {
                selectedCityID = cities.first?.id
            }
            state = .loaded
        } catch {
            if isFirstLoad { state = .failed(RepositoryError.from(error)) }
        }
    }

    func select(_ city: City) {
        selectedCityID = city.id
    }

    // Back from background: only the visible page refreshes; others do it when swiped to.
    func refreshSelectedIfStale() async {
        guard let selectedCity else { return }
        await detailViewModel(for: selectedCity).loadIfNeeded()
    }

    func detailViewModel(for city: City) -> CityDetailViewModel {
        if let existing = detailViewModels[city.id] { return existing }
        let viewModel = CityDetailViewModel(city: city, weatherRepository: weatherRepository)
        detailViewModels[city.id] = viewModel
        return viewModel
    }
}
