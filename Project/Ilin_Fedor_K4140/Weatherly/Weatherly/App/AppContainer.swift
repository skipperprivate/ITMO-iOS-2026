//
//  AppContainer.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// Composition root: the only place that decides which implementation backs each protocol.
final class AppContainer: Sendable {
    let weatherRepository: WeatherRepositoryProtocol
    let geocodingRepository: GeocodingRepositoryProtocol
    let favoritesRepository: FavoritesRepositoryProtocol
    let settingsRepository: SettingsRepositoryProtocol
    let appStateRepository: AppStateRepositoryProtocol

    init(
        weatherRepository: WeatherRepositoryProtocol,
        geocodingRepository: GeocodingRepositoryProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol,
        appStateRepository: AppStateRepositoryProtocol
    ) {
        self.weatherRepository = weatherRepository
        self.geocodingRepository = geocodingRepository
        self.favoritesRepository = favoritesRepository
        self.settingsRepository = settingsRepository
        self.appStateRepository = appStateRepository
    }

    // Live data from Open-Meteo behind a SwiftData cache, favourites in SwiftData. Both network
    // repositories share one client, so its concurrency limit covers every request the app makes.
    static func live() -> AppContainer {
        let client = NetworkClient.openMeteo
        let cache = CacheStoreHandle(container: PersistenceStack.cacheContainer())
        // Housekeeping once per launch, behind whatever the first screen loads.
        Task.detached(priority: .background) {
            try? await cache.purgeExpired(now: Date())
        }
        return AppContainer(
            weatherRepository: CachingWeatherRepository(
                upstream: CoalescingWeatherRepository(upstream: OpenMeteoWeatherRepository(client: client)),
                cache: cache
            ),
            geocodingRepository: CachingGeocodingRepository(
                upstream: OpenMeteoGeocodingRepository(client: client),
                cache: cache
            ),
            favoritesRepository: SwiftDataFavoritesRepository(container: PersistenceStack.favoritesContainer()),
            settingsRepository: UserDefaultsSettingsRepository(),
            appStateRepository: UserDefaultsAppStateRepository()
        )
    }
}
