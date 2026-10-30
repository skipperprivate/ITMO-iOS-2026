//
//  CachingGeocodingRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation
import OSLog

// Decorator over geocoding: typing back and forth repeats queries, and place names barely change.
// When the network fails, an outdated list still beats an error.
nonisolated final class CachingGeocodingRepository: GeocodingRepositoryProtocol, Sendable {
    private let upstream: GeocodingRepositoryProtocol
    private let cache: CacheStoreHandle
    private let now: @Sendable () -> Date
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Weatherly", category: "Cache")

    init(upstream: GeocodingRepositoryProtocol, cache: CacheStoreHandle, now: @escaping @Sendable () -> Date = Date.init) {
        self.upstream = upstream
        self.cache = cache
        self.now = now
    }

    var minimumQueryLength: Int {
        upstream.minimumQueryLength
    }

    func searchCities(matching query: String) async throws -> [City] {
        let key = Self.key(for: query)
        guard key.count >= minimumQueryLength else {
            return try await upstream.searchCities(matching: query)
        }
        let cached = await stored(forQuery: key)
        if let cached, isFresh(cached) {
            return cached.cities
        }
        do {
            let cities = try await upstream.searchCities(matching: query)
            await store(cities, forQuery: key)
            return cities
        } catch let error as RepositoryError {
            if let cached, !cached.cities.isEmpty { return cached.cities }
            throw error
        }
    }

    // The API ignores case and repeated spaces, so "  Нижний  новгород" and "нижний новгород" share a record.
    static func key(for query: String) -> String {
        OpenMeteoGeocodingRepository.normalized(query).lowercased()
    }

    private func isFresh(_ search: CachedSearch) -> Bool {
        let age = now().timeIntervalSince(search.fetchedAt)
        let lifetime = search.cities.isEmpty ? CacheLimits.emptySearchFreshInterval : CacheLimits.searchFreshInterval
        return age >= 0 && age < lifetime
    }

    private func stored(forQuery query: String) async -> CachedSearch? {
        do {
            return try await cache.store.value.searchResults(forQuery: query)
        } catch {
            logger.error("Search cache read failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private func store(_ cities: [City], forQuery query: String) async {
        do {
            try await cache.store.value.saveSearchResults(cities, forQuery: query, fetchedAt: now())
        } catch {
            logger.error("Search cache write failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
