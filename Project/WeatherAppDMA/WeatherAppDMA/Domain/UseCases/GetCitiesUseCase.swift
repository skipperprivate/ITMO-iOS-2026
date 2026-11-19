import Foundation

protocol GetCitiesUseCase: Sendable {
    func execute() async throws -> [CitySummary]
}

struct DefaultGetCitiesUseCase: GetCitiesUseCase {
    let repository: WeatherRepository

    func execute() async throws -> [CitySummary] {
        try await repository.fetchCities()
    }
}
