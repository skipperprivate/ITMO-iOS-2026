import Foundation

nonisolated protocol GeocodingRepositoryProtocol: Sendable {
    var minimumQueryLength: Int { get }

    func searchCities(matching query: String) async throws -> [City]
}
