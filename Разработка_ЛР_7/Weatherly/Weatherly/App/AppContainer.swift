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

    // Live data from Open-Meteo. Both repositories share one client, so its concurrency
    // limit covers every request the app makes.
    static func live() -> AppContainer {
        let client = NetworkClient.openMeteo
        return AppContainer(
            weatherRepository: CoalescingWeatherRepository(upstream: OpenMeteoWeatherRepository(client: client)),
            geocodingRepository: OpenMeteoGeocodingRepository(client: client),
            favoritesRepository: InMemoryFavoritesRepository(),
            settingsRepository: UserDefaultsSettingsRepository()
        )
    }
}
