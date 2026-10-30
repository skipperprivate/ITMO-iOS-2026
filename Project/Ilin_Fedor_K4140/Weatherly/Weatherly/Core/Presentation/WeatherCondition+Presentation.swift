//
//  WeatherCondition+Presentation.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

extension WeatherCondition {
    func symbolName(isDaytime: Bool) -> String {
        switch self {
        case .clearSky: isDaytime ? "sun.max.fill" : "moon.stars.fill"
        case .mostlyClear: isDaytime ? "sun.max.fill" : "moon.fill"
        case .partlyCloudy: isDaytime ? "cloud.sun.fill" : "cloud.moon.fill"
        case .cloudy: "cloud.fill"
        case .fog: "cloud.fog.fill"
        case .drizzle: "cloud.drizzle.fill"
        case .rain: "cloud.rain.fill"
        case .rainShowers: "cloud.heavyrain.fill"
        case .snow: "cloud.snow.fill"
        case .thunderstorm: "cloud.bolt.rain.fill"
        }
    }

    var label: String {
        switch self {
        case .clearSky: "Ясно"
        case .mostlyClear: "Малооблачно"
        case .partlyCloudy: "Переменная облачность"
        case .cloudy: "Пасмурно"
        case .fog: "Туман"
        case .drizzle: "Морось"
        case .rain: "Дождь"
        case .rainShowers: "Ливень"
        case .snow: "Снег"
        case .thunderstorm: "Гроза"
        }
    }

    var precipitationNoun: String {
        switch self {
        case .drizzle: "Морось"
        case .rainShowers: "Ливень"
        case .snow: "Снег"
        case .thunderstorm: "Гроза"
        default: "Дождь"
        }
    }
}
