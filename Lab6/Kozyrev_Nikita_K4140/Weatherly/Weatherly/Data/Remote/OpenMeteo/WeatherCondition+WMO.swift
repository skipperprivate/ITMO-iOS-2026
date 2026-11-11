//
//  WeatherCondition+WMO.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

// WMO 4677 codes as used by Open-Meteo (see "WMO Weather interpretation codes" in its docs).
nonisolated extension WeatherCondition {
    init(wmoCode: Int) {
        switch wmoCode {
        case 0: self = .clearSky
        case 1: self = .mostlyClear
        case 2: self = .partlyCloudy
        case 3: self = .cloudy
        // Snow showers override the rainy decade group.
        case 85, 86: self = .snow
        default: self = Self.decadeCondition(for: wmoCode)
        }
    }

    private static func decadeCondition(for wmoCode: Int) -> Self {
        switch wmoCode {
        case 40...49: .fog
        case 50...59: .drizzle
        case 60...69: .rain
        case 70...79: .snow
        case 80...89: .rainShowers
        case 90...99: .thunderstorm
        default: .cloudy
        }
    }
}
