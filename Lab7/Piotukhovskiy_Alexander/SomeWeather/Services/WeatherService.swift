import Foundation

enum ForecastLoadReason: Sendable {
    case initialLoad
    case userRefresh
}

protocol WeatherService: Sendable {
    func forecast(for city: City, reason: ForecastLoadReason) async throws -> WeatherForecast
}
