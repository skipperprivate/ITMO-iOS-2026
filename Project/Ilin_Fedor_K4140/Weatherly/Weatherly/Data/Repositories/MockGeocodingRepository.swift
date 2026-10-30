//
//  MockGeocodingRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

#if DEBUG
import Foundation

// Previews only; the app always talks to Open-Meteo.
nonisolated final class MockGeocodingRepository: GeocodingRepositoryProtocol, Sendable {
    let minimumQueryLength = 2
    private let catalog: [City]

    init(catalog: [City] = MockData.allCities) {
        self.catalog = catalog
    }

    func searchCities(matching query: String) async throws -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minimumQueryLength else { return [] }
        return catalog.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }
}
#endif
