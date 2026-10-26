//
//  PlacesViewModel.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// Weather of one card; a city whose request failed must not spin forever.
enum PlaceWeather: Equatable {
    case loading
    case loaded(CurrentWeather)
    case unavailable
}

@Observable
@MainActor
final class PlacesViewModel {
    enum State {
        case loading
        case loaded
        case failed(RepositoryError)
    }

    private(set) var state: State = .loading
    private(set) var cities: [City] = []
    private(set) var weather: [String: PlaceWeather] = [:]
    // Every city failed (typically offline); per-card fallbacks alone wouldn't say why.
    private(set) var weatherError: RepositoryError?

    private let favoritesRepository: FavoritesRepositoryProtocol
    private let weatherRepository: WeatherRepositoryProtocol

    init(favoritesRepository: FavoritesRepositoryProtocol, weatherRepository: WeatherRepositoryProtocol) {
        self.favoritesRepository = favoritesRepository
        self.weatherRepository = weatherRepository
    }

    func weather(for city: City) -> PlaceWeather {
        weather[city.id] ?? .loading
    }

    func load() async {
        if cities.isEmpty { state = .loading }
        do {
            cities = try await favoritesRepository.loadFavorites()
            state = .loaded
            await refreshWeather()
        } catch {
            if cities.isEmpty { state = .failed(RepositoryError.from(error)) }
        }
    }

    // One batch via the repository's TaskGroup; cards that already show weather keep it on failure.
    func refreshWeather() async {
        let requested = cities
        guard !requested.isEmpty else { return }
        for city in requested where !isLoaded(city) {
            weather[city.id] = .loading
        }
        do {
            let snapshots = try await weatherRepository.snapshots(for: requested)
            let byID = Dictionary(snapshots.map { ($0.city.id, $0.current) }, uniquingKeysWith: { first, _ in first })
            for city in requested {
                if let current = byID[city.id] {
                    weather[city.id] = .loaded(current)
                } else if !isLoaded(city) {
                    weather[city.id] = .unavailable
                }
            }
            weatherError = nil
        } catch is CancellationError {
            for city in requested where !isLoaded(city) {
                weather[city.id] = nil
            }
        } catch {
            for city in requested where !isLoaded(city) {
                weather[city.id] = .unavailable
            }
            weatherError = RepositoryError.from(error)
        }
    }

    func recoverAfterReconnect() async {
        let hasGaps = cities.contains { weather(for: $0) == .unavailable }
        guard weatherError != nil || hasGaps else { return }
        await refreshWeather()
    }

    func remove(at offsets: IndexSet) {
        let removed = offsets.map { cities[$0] }
        for index in offsets.sorted(by: >) {
            cities.remove(at: index)
        }
        for city in removed {
            weather[city.id] = nil
        }
        Task {
            for city in removed {
                try? await favoritesRepository.removeFavorite(city)
            }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        // Same index arithmetic as the repository, so screen and storage end up in one order.
        let itemsToMove = source.map { cities[$0] }
        for index in source.sorted(by: >) {
            cities.remove(at: index)
        }
        let removedBeforeDestination = source.filter { $0 < destination }.count
        let adjustedDestination = max(0, min(destination - removedBeforeDestination, cities.count))
        cities.insert(contentsOf: itemsToMove, at: adjustedDestination)
        Task {
            try? await favoritesRepository.moveFavorite(from: source, to: destination)
        }
    }

    private func isLoaded(_ city: City) -> Bool {
        if case .loaded = weather[city.id] { return true }
        return false
    }
}
