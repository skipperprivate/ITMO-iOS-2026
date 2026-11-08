import Foundation

struct OpenMeteoCityService: CityService {
    private let client: OpenMeteoClient

    init(client: OpenMeteoClient = OpenMeteoClient()) {
        self.client = client
    }

    func search(_ query: String) async throws -> [City] {
        try await client.searchCities(query)
    }
}
