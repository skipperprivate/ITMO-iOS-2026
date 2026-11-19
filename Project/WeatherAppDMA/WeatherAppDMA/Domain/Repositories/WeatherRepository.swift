import Foundation

protocol WeatherRepository: Sendable {
    func fetchWeather(for city: String) async throws -> Weather
    func fetchCities() async throws -> [CitySummary]
}
