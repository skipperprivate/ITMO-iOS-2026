import Foundation

nonisolated struct City: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let name: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double
    let timeZoneIdentifier: String

    var subtitle: String {
        [region, country].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.timeZone = timeZone
        return calendar
    }
}
