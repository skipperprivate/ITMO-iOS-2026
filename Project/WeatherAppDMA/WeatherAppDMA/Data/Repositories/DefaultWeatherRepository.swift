import Foundation

struct DefaultWeatherRepository: WeatherRepository {
    let dataSource: WeatherDataSource

    func fetchWeather(for city: String) async throws -> Weather {
        let dto = try await dataSource.loadWeather(for: city)
        return dto.toDomain()
    }

    func fetchCities() async throws -> [CitySummary] {
        let dtos = try await dataSource.loadCities()
        return dtos.map { $0.toDomain() }
    }
}
