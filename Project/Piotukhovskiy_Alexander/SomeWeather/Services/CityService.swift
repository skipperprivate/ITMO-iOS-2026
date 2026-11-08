import Foundation

protocol CityService: Sendable {
    func search(_ query: String) async throws -> [City]
}
