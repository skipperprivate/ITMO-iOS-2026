import Foundation

struct OpenMeteoWeatherService: WeatherService {
    private let client: OpenMeteoClient

    init(client: OpenMeteoClient = OpenMeteoClient()) {
        self.client = client
    }

    func forecast(for city: City, reason: ForecastLoadReason) async throws -> WeatherForecast {
        try await client.forecast(for: city)
    }
}
