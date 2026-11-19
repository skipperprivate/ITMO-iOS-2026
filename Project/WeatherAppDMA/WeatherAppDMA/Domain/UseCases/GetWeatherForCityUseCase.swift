import Foundation

protocol GetWeatherForCityUseCase: Sendable {
    func execute(city: String) async throws -> Weather
}

struct DefaultGetWeatherForCityUseCase: GetWeatherForCityUseCase {
    let repository: WeatherRepository

    func execute(city: String) async throws -> Weather {
        let trimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AppError.emptyQuery
        }
        return try await repository.fetchWeather(for: trimmed)
    }
}
