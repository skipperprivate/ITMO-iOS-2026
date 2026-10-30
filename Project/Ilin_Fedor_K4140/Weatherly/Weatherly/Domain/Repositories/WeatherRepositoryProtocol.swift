//
//  WeatherRepositoryProtocol.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// Errors are RepositoryError or CancellationError.
// Repositories without a cache implement only snapshot(for:); the rest has defaults.
nonisolated protocol WeatherRepositoryProtocol: Sendable {
    func snapshot(for city: City) async throws -> CityWeatherSnapshot

    func snapshot(for city: City, policy: CachePolicy) async throws -> CityWeatherSnapshot

    // Whatever is stored and still worth showing, without touching the network; nil if nothing.
    func cachedSnapshot(for city: City) async -> CityWeatherSnapshot?

    // Input order; cities that failed are skipped, throws only if all of them failed.
    func snapshots(for cities: [City], policy: CachePolicy) async throws -> [CityWeatherSnapshot]
}

nonisolated extension WeatherRepositoryProtocol {
    func snapshot(for city: City, policy: CachePolicy) async throws -> CityWeatherSnapshot {
        try await snapshot(for: city)
    }

    func cachedSnapshot(for city: City) async -> CityWeatherSnapshot? {
        nil
    }

    func snapshots(for cities: [City]) async throws -> [CityWeatherSnapshot] {
        try await snapshots(for: cities, policy: .returnFreshCache)
    }

    // One child task per city; every conformer (network, decorators, mocks) gets the same batch semantics.
    func snapshots(for cities: [City], policy: CachePolicy) async throws -> [CityWeatherSnapshot] {
        guard !cities.isEmpty else { return [] }
        let results = await withTaskGroup(of: (Int, Result<CityWeatherSnapshot, Error>).self) { group in
            for (index, city) in cities.enumerated() {
                group.addTask {
                    do {
                        return (index, .success(try await self.snapshot(for: city, policy: policy)))
                    } catch {
                        return (index, .failure(error))
                    }
                }
            }
            var results = [Result<CityWeatherSnapshot, Error>?](repeating: nil, count: cities.count)
            for await (index, result) in group {
                results[index] = result
            }
            return results.compactMap { $0 }
        }

        try Task.checkCancellation()
        let snapshots = results.compactMap { try? $0.get() }
        if snapshots.isEmpty, case .failure(let error)? = results.first {
            throw error
        }
        return snapshots
    }
}
