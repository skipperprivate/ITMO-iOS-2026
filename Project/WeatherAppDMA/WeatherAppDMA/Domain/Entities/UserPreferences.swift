import Foundation

enum TemperatureUnit: String, CaseIterable, Sendable, Codable, Identifiable {
    case celsius
    case fahrenheit

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .celsius:    return "°C"
        case .fahrenheit: return "°F"
        }
    }

    func convert(fromCelsius value: Double) -> Double {
        switch self {
        case .celsius:    return value
        case .fahrenheit: return value * 9 / 5 + 32
        }
    }
}

enum WindUnit: String, CaseIterable, Sendable, Codable, Identifiable {
    case metersPerSecond
    case kilometersPerHour

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .metersPerSecond:    return "м/с"
        case .kilometersPerHour:  return "км/ч"
        }
    }

    func convert(fromMetersPerSecond value: Double) -> Double {
        switch self {
        case .metersPerSecond:    return value
        case .kilometersPerHour:  return value * 3.6
        }
    }
}

struct UserPreferences: Equatable, Sendable {
    var temperatureUnit: TemperatureUnit
    var windUnit: WindUnit
    var lastOpenedCity: String?

    static let `default` = UserPreferences(
        temperatureUnit: .celsius,
        windUnit: .metersPerSecond,
        lastOpenedCity: nil
    )
}
