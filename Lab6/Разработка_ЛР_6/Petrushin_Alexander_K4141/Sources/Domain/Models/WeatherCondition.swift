//
//  WeatherCondition.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

nonisolated enum WeatherCondition: String, Codable, Sendable, CaseIterable {
    case clearSky
    case mostlyClear
    case partlyCloudy
    case cloudy
    case fog
    case drizzle
    case rain
    case rainShowers
    case snow
    case thunderstorm

    var isPrecipitation: Bool {
        switch self {
        case .drizzle, .rain, .rainShowers, .snow, .thunderstorm: true
        case .clearSky, .mostlyClear, .partlyCloudy, .cloudy, .fog: false
        }
    }
}
