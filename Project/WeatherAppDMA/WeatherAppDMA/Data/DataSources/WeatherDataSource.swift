import Foundation

protocol WeatherDataSource: Sendable {
    func loadWeather(for city: String) async throws -> WeatherDTO
    func loadCities() async throws -> [CityDTO]
}
