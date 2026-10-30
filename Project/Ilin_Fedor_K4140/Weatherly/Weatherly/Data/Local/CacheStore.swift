//
//  CacheStore.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation
import SwiftData

nonisolated enum CacheLimits {
    // Bump on any change to the encoded domain types (City, CityWeatherSnapshot and what they hold):
    // older records then read as misses instead of failing to decode.
    static let payloadVersion = 1

    static let forecastRetention: TimeInterval = 7 * 24 * 3600
    static let maximumForecasts = 30

    // Places barely change, so a found list stays good for a week; "nothing found" may be a typo
    // that becomes a real place in the next GeoNames update.
    static let searchFreshInterval: TimeInterval = 7 * 24 * 3600
    static let emptySearchFreshInterval: TimeInterval = 24 * 3600
    static let searchRetention: TimeInterval = 30 * 24 * 3600
    static let maximumSearches = 100
}

nonisolated struct CachedSearch: Sendable {
    let cities: [City]
    let fetchedAt: Date
}

// All SwiftData work on the cache; only domain values leave the actor.
@ModelActor
actor CacheStore {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: Forecasts

    func forecast(forKey key: String) throws -> CityWeatherSnapshot? {
        guard let record = try modelContext.fetch(Self.forecastDescriptor(key: key)).first else { return nil }
        guard record.payloadVersion == CacheLimits.payloadVersion,
              let snapshot = try? decoder.decode(CityWeatherSnapshot.self, from: record.payload) else {
            modelContext.delete(record)
            try save()
            return nil
        }
        return snapshot
    }

    func saveForecast(_ snapshot: CityWeatherSnapshot, forKey key: String) throws {
        let payload = try encoder.encode(snapshot)
        if let record = try modelContext.fetch(Self.forecastDescriptor(key: key)).first {
            record.fetchedAt = snapshot.fetchedAt
            record.payloadVersion = CacheLimits.payloadVersion
            record.payload = payload
        } else {
            modelContext.insert(CachedForecastRecord(
                key: key,
                fetchedAt: snapshot.fetchedAt,
                payloadVersion: CacheLimits.payloadVersion,
                payload: payload
            ))
        }
        try save()
    }

    // MARK: Searches

    func searchResults(forQuery query: String) throws -> CachedSearch? {
        guard let record = try modelContext.fetch(Self.searchDescriptor(query: query)).first else { return nil }
        guard record.payloadVersion == CacheLimits.payloadVersion,
              let cities = try? decoder.decode([City].self, from: record.payload) else {
            modelContext.delete(record)
            try save()
            return nil
        }
        return CachedSearch(cities: cities, fetchedAt: record.fetchedAt)
    }

    func saveSearchResults(_ cities: [City], forQuery query: String, fetchedAt: Date) throws {
        let payload = try encoder.encode(cities)
        if let record = try modelContext.fetch(Self.searchDescriptor(query: query)).first {
            record.fetchedAt = fetchedAt
            record.resultCount = cities.count
            record.payloadVersion = CacheLimits.payloadVersion
            record.payload = payload
        } else {
            modelContext.insert(CachedSearchRecord(
                query: query,
                fetchedAt: fetchedAt,
                resultCount: cities.count,
                payloadVersion: CacheLimits.payloadVersion,
                payload: payload
            ))
        }
        try save()
    }

    // MARK: Housekeeping

    // Age limits first, then the oldest records over the count limit.
    // Favourites stay among the newest on their own: Places refreshes all of them together.
    func purge(now: Date) throws {
        let forecastCutoff = now.addingTimeInterval(-CacheLimits.forecastRetention)
        try modelContext.delete(model: CachedForecastRecord.self, where: #Predicate { $0.fetchedAt < forecastCutoff })

        let searchCutoff = now.addingTimeInterval(-CacheLimits.searchRetention)
        let emptySearchCutoff = now.addingTimeInterval(-CacheLimits.emptySearchFreshInterval)
        try modelContext.delete(model: CachedSearchRecord.self, where: #Predicate {
            $0.fetchedAt < searchCutoff || ($0.resultCount == 0 && $0.fetchedAt < emptySearchCutoff)
        })

        var forecasts = FetchDescriptor<CachedForecastRecord>(sortBy: [SortDescriptor(\.fetchedAt, order: .reverse)])
        forecasts.fetchOffset = CacheLimits.maximumForecasts
        for record in try modelContext.fetch(forecasts) {
            modelContext.delete(record)
        }
        var searches = FetchDescriptor<CachedSearchRecord>(sortBy: [SortDescriptor(\.fetchedAt, order: .reverse)])
        searches.fetchOffset = CacheLimits.maximumSearches
        for record in try modelContext.fetch(searches) {
            modelContext.delete(record)
        }
        try save()
    }

    // MARK: Helpers

    private nonisolated static func forecastDescriptor(key: String) -> FetchDescriptor<CachedForecastRecord> {
        var descriptor = FetchDescriptor<CachedForecastRecord>(predicate: #Predicate { $0.key == key })
        descriptor.fetchLimit = 1
        return descriptor
    }

    private nonisolated static func searchDescriptor(query: String) -> FetchDescriptor<CachedSearchRecord> {
        var descriptor = FetchDescriptor<CachedSearchRecord>(predicate: #Predicate { $0.query == query })
        descriptor.fetchLimit = 1
        return descriptor
    }

    private func save() throws {
        guard modelContext.hasChanges else { return }
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}

// One cache actor shared by both caching repositories. Created in a detached task:
// a @ModelActor made on the main thread would do all its work there.
nonisolated final class CacheStoreHandle: Sendable {
    let store: Task<CacheStore, Never>

    init(container: ModelContainer) {
        store = Task.detached { CacheStore(modelContainer: container) }
    }

    func purgeExpired(now: Date) async throws {
        try await store.value.purge(now: now)
    }
}
