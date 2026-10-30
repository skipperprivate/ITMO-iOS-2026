//
//  AppSettings.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

nonisolated enum TemperatureUnit: String, Codable, CaseIterable, Identifiable, Sendable {
    case celsius, fahrenheit

    var id: String { rawValue }
    var symbol: String { self == .celsius ? "°C" : "°F" }

    func convert(fromCelsius value: Double) -> Double {
        switch self {
        case .celsius: value
        case .fahrenheit: value * 9 / 5 + 32
        }
    }
}

nonisolated enum WindSpeedUnit: String, Codable, CaseIterable, Identifiable, Sendable {
    case metersPerSecond, kilometersPerHour, milesPerHour, knots

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .metersPerSecond: "м/с"
        case .kilometersPerHour: "км/ч"
        case .milesPerHour: "миль/ч"
        case .knots: "уз"
        }
    }

    func convert(fromKmh value: Double) -> Double {
        switch self {
        case .kilometersPerHour: value
        case .metersPerSecond: value / 3.6
        case .milesPerHour: value / 1.609344
        case .knots: value / 1.852
        }
    }
}

nonisolated enum PressureUnit: String, Codable, CaseIterable, Identifiable, Sendable {
    case millimetersOfMercury, hectopascals, inchesOfMercury

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .millimetersOfMercury: "мм рт. ст."
        case .hectopascals: "гПа"
        case .inchesOfMercury: "дюйм рт. ст."
        }
    }

    func convert(fromHPa value: Double) -> Double {
        switch self {
        case .hectopascals: value
        case .millimetersOfMercury: value * 0.750062
        case .inchesOfMercury: value * 0.0295300
        }
    }
}

// auto: light by day, dark at night in the Home city; resolved in the App layer.
nonisolated enum AppTheme: String, Codable, CaseIterable, Identifiable, Sendable {
    case auto, light, dark

    var id: String { rawValue }
    var label: String {
        switch self {
        case .auto: "Авто"
        case .light: "Светлое"
        case .dark: "Тёмное"
        }
    }
}

nonisolated struct AppSettings: Codable, Equatable, Sendable {
    var temperatureUnit: TemperatureUnit = .celsius
    var windSpeedUnit: WindSpeedUnit = .metersPerSecond
    var pressureUnit: PressureUnit = .millimetersOfMercury
    var theme: AppTheme = .auto

    static let `default` = AppSettings()
}

// Missing or unknown fields fall back to defaults instead of resetting everything.
nonisolated extension AppSettings {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        temperatureUnit = (try? container.decodeIfPresent(TemperatureUnit.self, forKey: .temperatureUnit)) ?? .celsius
        windSpeedUnit = (try? container.decodeIfPresent(WindSpeedUnit.self, forKey: .windSpeedUnit)) ?? .metersPerSecond
        pressureUnit = (try? container.decodeIfPresent(PressureUnit.self, forKey: .pressureUnit)) ?? .millimetersOfMercury
        theme = (try? container.decodeIfPresent(AppTheme.self, forKey: .theme)) ?? .auto
    }
}
