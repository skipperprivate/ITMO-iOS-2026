import Foundation

struct GeocodingResponseDTO: Decodable, Sendable {
    let results: [CityDTO]?

    var cities: [City] { (results ?? []).map { $0.toCity() } }
}

struct CityDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let countryCode: String?
    let admin1: String?
    let timezone: String?

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, country, admin1, timezone
        case countryCode = "country_code"
    }

    func toCity() -> City {
        City(id: id, name: name, latitude: latitude, longitude: longitude,
             country: country, countryCode: countryCode?.uppercased(),
             region: admin1, timezone: timezone)
    }
}

struct APIErrorDTO: Decodable, Sendable {
    let error: Bool
    let reason: String
}
