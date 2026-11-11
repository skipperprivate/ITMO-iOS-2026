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
    // A removal or reorder that didn't reach storage; the list is already reloaded from it.
    private(set) var editError: RepositoryError?

    private let favoritesRepository: FavoritesRepositoryProtocol
    private let weatherRepository: WeatherRepositoryProtocol
    @ObservationIgnored private var pendingWrite: Task<Void, Never>?

    init(favoritesRepository: FavoritesRepositoryProtocol, weatherRepository: WeatherRepositoryProtocol) {
        self.favoritesRepository = favoritesRepository
        self.weatherRepository = weatherRepository
    }

    func weather(for city: City) -> PlaceWeather {
        weather[city.id] ?? .loading
    }

    func load() async {
        if cities.isEmpty { state = .loading }
        // Reading before queued edits land would bring removed cities back for a moment.
        await pendingWrite?.value
        do {
            cities = try await favoritesRepository.loadFavorites()
            editError = nil
            state = .loaded
            await showStoredWeather()
            await refreshWeather()
        } catch {
            let error = RepositoryError.from(error)
            if cities.isEmpty {
                state = .failed(error)
            } else {
                editError = error
            }
        }
    }

    // Cards fill from the cache at once instead of spinning while the network is asked.
    private func showStoredWeather() async {
        for city in cities where !isLoaded(city) {
            if let cached = await weatherRepository.cachedSnapshot(for: city) {
                weather[city.id] = .loaded(cached.current)
            }
        }
    }

    // One batch via the repository's TaskGroup; cards that already show weather keep it on failure.
    func refreshWeather(policy: CachePolicy = .returnFreshCache) async {
        let requested = cities
        guard !requested.isEmpty else { return }
        for city in requested where !isLoaded(city) {
            weather[city.id] = .loading
        }
        do {
            let snapshots = try await weatherRepository.snapshots(for: requested, policy: policy)
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

    // The list changes at once; storage follows through the write queue.
    func remove(at offsets: IndexSet) {
        let removed = offsets.map { cities[$0] }
        for index in offsets.sorted(by: >) {
            cities.remove(at: index)
        }
        for city in removed {
            weather[city.id] = nil
        }
        let favoritesRepository = favoritesRepository
        enqueueWrite {
            for city in removed {
                try await favoritesRepository.removeFavorite(id: city.id)
            }
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        // List.onMove semantics: `destination` is an index in the list before the move.
        let itemsToMove = source.map { cities[$0] }
        for index in source.sorted(by: >) {
            cities.remove(at: index)
        }
        let removedBeforeDestination = source.filter { $0 < destination }.count
        let adjustedDestination = max(0, min(destination - removedBeforeDestination, cities.count))
        cities.insert(contentsOf: itemsToMove, at: adjustedDestination)
        // The whole resulting order, not the indices: storage may hold a city this list doesn't.
        let ids = cities.map(\.id)
        let favoritesRepository = favoritesRepository
        enqueueWrite { try await favoritesRepository.reorderFavorites(ids) }
    }

    // Writes run one after another in the order the user made them; separate tasks could reach
    // storage in any order. After a failure the list is reloaded from storage, the source of truth.
    private func enqueueWrite(_ write: @escaping @Sendable () async throws -> Void) {
        let previous = pendingWrite
        pendingWrite = Task {
            await previous?.value
            do {
                try await write()
            } catch {
                editError = RepositoryError.from(error)
                if let stored = try? await favoritesRepository.loadFavorites() {
                    cities = stored
                }
            }
        }
    }

    private func isLoaded(_ city: City) -> Bool {
        if case .loaded = weather[city.id] { return true }
        return false
    }
}
