import Foundation

enum ForecastLoadReason: Sendable {
    case initialLoad
    case userRefresh
}

@MainActor
protocol WeatherService {
    func forecast(for city: City, reason: ForecastLoadReason) async throws -> WeatherForecast
}
