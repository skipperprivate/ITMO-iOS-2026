//
//  WeatherRepositoryProtocol.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// Errors are RepositoryError or CancellationError.
nonisolated protocol WeatherRepositoryProtocol: Sendable {
    func snapshot(for city: City) async throws -> CityWeatherSnapshot

    // Input order; cities that failed are skipped, throws only if all of them failed.
    func snapshots(for cities: [City]) async throws -> [CityWeatherSnapshot]
}

// One child task per city; every conformer (network, decorators, mocks) gets the same batch semantics.
nonisolated extension WeatherRepositoryProtocol {
    func snapshots(for cities: [City]) async throws -> [CityWeatherSnapshot] {
        guard !cities.isEmpty else { return [] }
        let results = await withTaskGroup(of: (Int, Result<CityWeatherSnapshot, Error>).self) { group in
            for (index, city) in cities.enumerated() {
                group.addTask {
                    do {
                        return (index, .success(try await self.snapshot(for: city)))
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
