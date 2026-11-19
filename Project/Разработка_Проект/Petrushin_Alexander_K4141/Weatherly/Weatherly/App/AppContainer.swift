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

    init(
        weatherRepository: WeatherRepositoryProtocol,
        geocodingRepository: GeocodingRepositoryProtocol,
        favoritesRepository: FavoritesRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.weatherRepository = weatherRepository
        self.geocodingRepository = geocodingRepository
        self.favoritesRepository = favoritesRepository
        self.settingsRepository = settingsRepository
    }

    // In Debug builds, use the bundled deterministic demo data so the app remains
    // usable when this Mac/network cannot reach Open-Meteo. Release builds use live API.
    static func live() -> AppContainer {
        #if DEBUG
        return AppContainer(
            weatherRepository: MockWeatherRepository(),
            geocodingRepository: MockGeocodingRepository(),
            favoritesRepository: InMemoryFavoritesRepository(),
            settingsRepository: UserDefaultsSettingsRepository()
        )
        #else
        let client = NetworkClient.openMeteo
        return AppContainer(
            weatherRepository: CoalescingWeatherRepository(upstream: OpenMeteoWeatherRepository(client: client)),
            geocodingRepository: OpenMeteoGeocodingRepository(client: client),
            favoritesRepository: InMemoryFavoritesRepository(),
            settingsRepository: UserDefaultsSettingsRepository()
        )
        #endif
    }
}
