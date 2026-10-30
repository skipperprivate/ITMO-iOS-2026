//
//  CachingWeatherRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation
import OSLog

// Decorator over the network chain (Caching → Coalescing → OpenMeteo). A fresh record answers
// without a request; anything older only serves cachedSnapshot(for:), so the screen can show it
// while the network is asked. Writing is best effort: a cache failure never fails a load.
nonisolated final class CachingWeatherRepository: WeatherRepositoryProtocol, Sendable {
    private let upstream: WeatherRepositoryProtocol
    private let cache: CacheStoreHandle
    private let now: @Sendable () -> Date
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Weatherly", category: "Cache")

    init(upstream: WeatherRepositoryProtocol, cache: CacheStoreHandle, now: @escaping @Sendable () -> Date = Date.init) {
        self.upstream = upstream
        self.cache = cache
        self.now = now
    }

    func snapshot(for city: City) async throws -> CityWeatherSnapshot {
        try await snapshot(for: city, policy: .returnFreshCache)
    }

    func snapshot(for city: City, policy: CachePolicy) async throws -> CityWeatherSnapshot {
        if policy == .returnFreshCache,
           let cached = await stored(for: city),
           ForecastFreshness.isFresh(cached.fetchedAt, now: now()) {
            return cached
        }
        let snapshot = try await upstream.snapshot(for: city, policy: policy)
        await store(snapshot, for: city)
        return snapshot
    }

    func cachedSnapshot(for city: City) async -> CityWeatherSnapshot? {
        guard let cached = await stored(for: city),
              ForecastFreshness.isDisplayable(cached.fetchedAt, now: now()) else { return nil }
        return cached
    }

    // Same rounding as the request: places closer than that get one forecast anyway.
    static func key(for city: City) -> String {
        let format = { (value: Double) in String(format: "%.4f", locale: Locale(identifier: "en_US_POSIX"), value) }
        return "\(format(city.latitude))|\(format(city.longitude))|\(city.timeZoneIdentifier)"
    }

    private func stored(for city: City) async -> CityWeatherSnapshot? {
        do {
            return try await cache.store.value.forecast(forKey: Self.key(for: city))?.with(city: city)
        } catch {
            logger.error("Forecast cache read failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private func store(_ snapshot: CityWeatherSnapshot, for city: City) async {
        do {
            try await cache.store.value.saveForecast(snapshot, forKey: Self.key(for: city))
        } catch {
            logger.error("Forecast cache write failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
