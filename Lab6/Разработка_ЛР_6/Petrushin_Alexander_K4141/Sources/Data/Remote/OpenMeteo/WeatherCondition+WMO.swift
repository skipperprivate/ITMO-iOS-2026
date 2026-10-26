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
        case 45, 48: self = .fog
        case 51, 53, 55, 56, 57: self = .drizzle
        case 61, 63, 65, 66, 67: self = .rain
        case 71, 73, 75, 77, 85, 86: self = .snow
        case 80, 81, 82: self = .rainShowers
        case 95, 96, 99: self = .thunderstorm
        // Codes outside Open-Meteo's subset: fall back to the WMO decade group.
        case 40...49: self = .fog
        case 50...59: self = .drizzle
        case 60...69: self = .rain
        case 70...79: self = .snow
        case 80...89: self = .rainShowers
        case 90...99: self = .thunderstorm
        default: self = .cloudy
        }
    }
}
