//
//  WeatherCondition.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 04.10.2026.
//

import Foundation
import SwiftUI

public struct WeatherCondition: Equatable, Hashable {
    let description: String
    let sfSymbolName: sfSymbolNameDayNNightDiff
    let iconColor: iconColorDayNNighntDiff
    let backgroundColorsDarkTheme: ColorsDayNNightDiff
    let backgroundColorsLightTheme: ColorsDayNNightDiff
}

enum sfSymbolNameDayNNightDiff: Equatable, Hashable{
    case same(String)
    case diff(String, String)
}

enum iconColorDayNNighntDiff: Equatable, Hashable {
    case same(Color)
    case diff(Color, Color)
}

enum ColorsDayNNightDiff: Equatable, Hashable {
    case single([Color])
    case pair([Color], [Color])
}

extension WeatherCondition{
    //Я выделил 10 основных состояний погодыю Остальные WeatherCode будем приводить к ним
    
    public static let defaultWeatherCondition = WeatherCondition( //Clear
        description: "Ясно",
        sfSymbolName: .diff("sun.max.fill", "moon.stars.fill"),
        iconColor: .diff(.orange, .indigo),
        backgroundColorsDarkTheme: .pair(
            [Color(red: 0.13, green: 0.17, blue: 0.24), Color(red: 0.08, green: 0.10, blue: 0.15)],
            [Color(red: 0.08, green: 0.10, blue: 0.18), Color(red: 0.05, green: 0.06, blue: 0.11)]),
        backgroundColorsLightTheme: .pair(
            [Color(red: 0.88, green: 0.94, blue: 1.0), Color(red: 0.95, green: 0.97, blue: 1.0)],
            [Color(red: 0.90, green: 0.92, blue: 0.97), Color(red: 0.95, green: 0.95, blue: 0.98)])
    )
    
    public static let weatherConditionsDict: [Int : WeatherCondition] = [
        0 : defaultWeatherCondition,
        
        2: WeatherCondition( //Partly cloudy
            description: "Переменная облачность",
            sfSymbolName: .diff("cloud.sun.fill", "cloud.moon.fill"),
            iconColor: .diff(.orange.opacity(0.9), .indigo.opacity(0.9)),
            backgroundColorsDarkTheme: .pair(
                [Color(red: 0.14, green: 0.17, blue: 0.22), Color(red: 0.09, green: 0.11, blue: 0.15)],
                [Color(red: 0.10, green: 0.11, blue: 0.18), Color(red: 0.06, green: 0.07, blue: 0.12)]),
            backgroundColorsLightTheme: .pair(
                [Color(red: 0.90, green: 0.94, blue: 0.98), Color(red: 0.95, green: 0.97, blue: 0.99)],
                [Color(red: 0.91, green: 0.92, blue: 0.97), Color(red: 0.95, green: 0.96, blue: 0.98)])),
        
        3: WeatherCondition( //Overcast
            description: "Облачно",
            sfSymbolName: .same("smoke.fill"),
            iconColor: .same(.secondary),
            backgroundColorsDarkTheme: .single(reusableBackgroundColors.overcastColors(for: .dark)),
            backgroundColorsLightTheme: .single(reusableBackgroundColors.overcastColors(for: .light))),
        
        45: WeatherCondition( //Fog
            description: "Туман",
            sfSymbolName: .same("cloud.fog.fill"),
            iconColor: .same(.secondary),
            backgroundColorsDarkTheme: .single(reusableBackgroundColors.overcastColors(for: .dark)),
            backgroundColorsLightTheme: .single(reusableBackgroundColors.overcastColors(for: .light))),
        
        50: WeatherCondition( //Drizzle
            description: "Моросящий дождь",
            sfSymbolName: .same("cloud.drizzle.fill"),
            iconColor: .same(.blue),
            backgroundColorsDarkTheme: .single(reusableBackgroundColors.rainColors(for: .dark)),
            backgroundColorsLightTheme: .single(reusableBackgroundColors.rainColors(for: .light))),
        
        60: WeatherCondition( //Rain
            description: "Дождь",
            sfSymbolName: .same("cloud.rain.fill"),
            iconColor: .same(.blue),
            backgroundColorsDarkTheme: .single(reusableBackgroundColors.rainColors(for: .dark)),
            backgroundColorsLightTheme: .single(reusableBackgroundColors.rainColors(for: .light))),
        
        65: WeatherCondition( //Heavy Rain
            description: "Ливень",
            sfSymbolName: .same("cloud.heavyrain.fill"),
            iconColor: .same(.blue),
            backgroundColorsDarkTheme: .single(reusableBackgroundColors.rainColors(for: .dark)),
            backgroundColorsLightTheme: .single(reusableBackgroundColors.rainColors(for: .light))),
        
        67: WeatherCondition( //Sleet
            description: "Мокрый снег",
            sfSymbolName: .same("cloud.sleet.fill"),
            iconColor: .same(.blue),
            backgroundColorsDarkTheme: .single(reusableBackgroundColors.snowColors(for: .dark)),
            backgroundColorsLightTheme: .single(reusableBackgroundColors.snowColors(for: .light))),
        
        70: WeatherCondition( //Snow
            description: "Снег",
            sfSymbolName: .same("snowflake"),
            iconColor: .same(.cyan),
            backgroundColorsDarkTheme: .single(reusableBackgroundColors.snowColors(for: .dark)),
            backgroundColorsLightTheme: .single(reusableBackgroundColors.snowColors(for: .light))),
        
        95: WeatherCondition( //Thunderstorm
            description: "Гроза",
            sfSymbolName: .same("cloud.bolt.rain.fill"),
            iconColor: .same(.yellow),
            backgroundColorsDarkTheme: .single(
                [Color(red: 0.14, green: 0.13, blue: 0.20), Color(red: 0.08, green: 0.07, blue: 0.13)]),
            backgroundColorsLightTheme: .single(
                [Color(red: 0.89, green: 0.90, blue: 0.96), Color(red: 0.94, green: 0.95, blue: 0.98)]))
    
    ]
    
    private struct reusableBackgroundColors{
        public static func overcastColors(for colorScheme: ColorScheme) -> [Color] {
            if colorScheme == .dark{
                return [Color(white: 0.16), Color(white: 0.10)]
            } else{
                return [Color(red: 0.91, green: 0.93, blue: 0.95), Color(red: 0.95, green: 0.96, blue: 0.98)]
            }
        }
        
        public static func rainColors(for colorScheme: ColorScheme) -> [Color] {
            if colorScheme == .dark{
                return [Color(red: 0.11, green: 0.15, blue: 0.22), Color(red: 0.07, green: 0.09, blue: 0.14)]
            } else{
                return [Color(red: 0.88, green: 0.92, blue: 0.96), Color(red: 0.94, green: 0.96, blue: 0.98)]
            }
        }
        
        public static func snowColors(for colorScheme: ColorScheme) -> [Color] {
            if colorScheme == .dark{
                return [Color(red: 0.13, green: 0.17, blue: 0.21), Color(red: 0.08, green: 0.11, blue: 0.14)]
            } else{
                return [Color(red: 0.91, green: 0.95, blue: 0.99), Color(red: 0.96, green: 0.98, blue: 1.0)]
            }
        }
    }
}
