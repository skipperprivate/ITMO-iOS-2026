//
//  OpenMeteoGeocodingRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

nonisolated final class OpenMeteoGeocodingRepository: GeocodingRepositoryProtocol, Sendable {
    // Open-Meteo returns nothing for a single character, so don't spend a request on it.
    let minimumQueryLength = 2

    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient.openMeteo) {
        self.client = client
    }

    // The API matches names literally: "ростов на дону" finds nothing, "ростов-на-дону" does,
    // while "нижний новгород" works only with the space. So multi-word queries try both spellings at once.
    func searchCities(matching query: String) async throws -> [City] {
        let name = Self.normalized(query)
        guard name.count >= minimumQueryLength else { return [] }
        guard name.contains(" ") else {
            return try await search(name)
        }

        async let spaced = result { try await self.search(name) }
        async let hyphenated = result { try await self.search(name.replacingOccurrences(of: " ", with: "-")) }
        let (primary, alternative) = await (spaced, hyphenated)
        try Task.checkCancellation()

        switch (primary, alternative) {
        case (.failure(let error), .failure):
            throw error
        default:
            let cities = ((try? primary.get()) ?? []) + ((try? alternative.get()) ?? [])
            var seen = Set<String>()
            return cities.filter { seen.insert($0.id).inserted }
        }
    }

    // "  нижний   новгород " → "нижний новгород".
    static func normalized(_ query: String) -> String {
        query.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    private func search(_ name: String) async throws -> [City] {
        try await RepositoryError.translating {
            let dto = try await client.send(OpenMeteoAPI.search(name: name))
            return OpenMeteoMapper.cities(from: dto)
        }
    }

    private func result(_ operation: () async throws -> [City]) async -> Result<[City], Error> {
        do {
            return .success(try await operation())
        } catch {
            return .failure(error)
        }
    }
}
