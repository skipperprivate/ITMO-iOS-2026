import Foundation

nonisolated struct OpenMeteoGeocodingDTO: Decodable, Sendable {
    let results: [Location]?

    nonisolated struct Location: Decodable, Sendable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
        let featureCode: String?
        let countryCode: String?
        let country: String?
        let admin1: String?
        let timezone: String?
        let population: Int?

        enum CodingKeys: String, CodingKey {
            case id, name, latitude, longitude, country, admin1, timezone, population
            case featureCode = "feature_code"
            case countryCode = "country_code"
        }
    }
}

nonisolated struct OpenMeteoErrorDTO: Decodable, Sendable {
    let reason: String?

    enum CodingKeys: String, CodingKey {
        case error, reason
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let reason = try? container.decodeIfPresent(String.self, forKey: .reason)
        let errorText = try? container.decodeIfPresent(String.self, forKey: .error)
        self.reason = [reason, errorText].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.first { !$0.isEmpty }
    }
}
