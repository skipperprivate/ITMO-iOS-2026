import Foundation

@MainActor
protocol CityService {
    var availableCities: [City] { get }
    func search(_ query: String) async throws -> [City]
}
