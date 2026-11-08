import Foundation

struct City: Identifiable, Codable, Equatable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let countryCode: String?
    let region: String?
    let timezone: String?

    var countryName: String {
        if let country, !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return country
        }
        if let code = countryCode?.uppercased(),
           let localized = Locale(identifier: "ru_RU").localizedString(forRegionCode: code) {
            return localized
        }
        return "Страна не указана"
    }

    var locationDetails: String {
        guard let region, !region.isEmpty, region != name else { return countryName }
        return "\(region), \(countryName)"
    }

    var displayTimeZone: TimeZone {
        timezone.flatMap { TimeZone(identifier: $0) } ?? TimeZone(secondsFromGMT: 0)!
    }
}

struct CityHistoryEntry: Identifiable, Equatable, Sendable {
    let city: City
    let lastSelectedAt: Date
    var id: Int { city.id }
}
