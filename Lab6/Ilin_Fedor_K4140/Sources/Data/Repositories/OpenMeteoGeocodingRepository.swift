import Foundation

nonisolated final class OpenMeteoGeocodingRepository: GeocodingRepositoryProtocol, Sendable {
    let minimumQueryLength = 2

    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient.openMeteo) {
        self.client = client
    }

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
