import Foundation
import SwiftData

@Model
final class SavedCity {
    @Attribute(.unique) var cityID: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var country: String?
    var countryCode: String?
    var region: String?
    var timezone: String?
    var lastSelectedAt: Date

    init(city: City, selectedAt: Date) {
        cityID = city.id
        name = city.name
        latitude = city.latitude
        longitude = city.longitude
        country = city.country
        countryCode = city.countryCode
        region = city.region
        timezone = city.timezone
        lastSelectedAt = selectedAt
    }

    var city: City {
        City(id: cityID, name: name, latitude: latitude, longitude: longitude,
             country: country, countryCode: countryCode, region: region, timezone: timezone)
    }

    func update(from city: City, selectedAt: Date) {
        name = city.name
        latitude = city.latitude
        longitude = city.longitude
        country = city.country
        countryCode = city.countryCode
        region = city.region
        timezone = city.timezone
        lastSelectedAt = selectedAt
    }
}
