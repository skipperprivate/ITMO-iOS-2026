import Foundation

nonisolated final class OpenMeteoWeatherRepository: WeatherRepositoryProtocol, Sendable {
    private let client: NetworkClientProtocol
    private let now: @Sendable () -> Date

    init(client: NetworkClientProtocol = NetworkClient.openMeteo, now: @escaping @Sendable () -> Date = Date.init) {
        self.client = client
        self.now = now
    }

    func snapshot(for city: City) async throws -> CityWeatherSnapshot {
        try await RepositoryError.translating {
            let endpoint = OpenMeteoAPI.forecast(
                latitude: city.latitude,
                longitude: city.longitude,
                timeZoneIdentifier: city.timeZoneIdentifier
            )
            let dto = try await client.send(endpoint)
            return try await Self.map(dto, city: city, fetchedAt: now())
        }
    }

    @concurrent
    private static func map(_ dto: OpenMeteoForecastDTO, city: City, fetchedAt: Date) async throws -> CityWeatherSnapshot {
        try OpenMeteoMapper.snapshot(from: dto, city: city, fetchedAt: fetchedAt)
    }
}
