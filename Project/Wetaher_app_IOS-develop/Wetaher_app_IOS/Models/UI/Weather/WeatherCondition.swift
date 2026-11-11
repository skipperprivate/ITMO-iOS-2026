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

enum sfSymbolNameDayNNightDiff: Equatable, Hashable {
    case same(String)
    case diff(String, String)
}

enum iconColorDayNNighntDiff: Equatable, Hashable {
    case same([Color])
    case diff([Color], [Color])
}

enum ColorsDayNNightDiff: Equatable, Hashable {
    case single([Color])
    case pair([Color], [Color])
}

extension WeatherCondition{
    // Я выделил 10 основных состояний погодыю Остальные WeatherCode будем приводить к ним
    
    public static let defaultWeatherCondition = WeatherCondition( // Clear
        description: BaseText.WeatherCondition.clear,
        sfSymbolName: .diff("sun.max.fill", "moon.stars.fill"),
        iconColor: .diff([BaseColors.orange], [BaseColors.indigo, BaseColors.yellow]),
        backgroundColorsDarkTheme: .pair(
            BaseColors.clearSkyDarkDay,
            BaseColors.clearSkyDarkNight),
        backgroundColorsLightTheme: .pair(
            BaseColors.clearSkyLightDay,
            BaseColors.clearSkyLightNight)
    )
    
    public static let weatherConditionsDict: [Int : WeatherCondition] = [
        0 : defaultWeatherCondition,
        
        2: WeatherCondition( //Partly cloudy
            description: BaseText.WeatherCondition.partlyCloudy,
            sfSymbolName: .diff("cloud.sun.fill", "cloud.moon.fill"),
            iconColor: .diff(
                [BaseColors.gray, BaseColors.orange.opacity(BaseNumeral.dimmedIconOpacity)],
                [BaseColors.gray, BaseColors.indigo.opacity(BaseNumeral.dimmedIconOpacity)]),
            backgroundColorsDarkTheme: .pair(
                BaseColors.partlyCloudyDarkDay,
                BaseColors.partlyCloudyDarkNight),
            backgroundColorsLightTheme: .pair(
                BaseColors.partlyCloudyLightDay,
                BaseColors.partlyCloudyLightNight)),
        
        3: WeatherCondition( //Overcast
            description: BaseText.WeatherCondition.overcast,
            sfSymbolName: .same("smoke.fill"),
            iconColor: .same([BaseColors.gray]),
            backgroundColorsDarkTheme: .single(BaseColors.overcastDark),
            backgroundColorsLightTheme: .single(BaseColors.overcastLight)),
        
        45: WeatherCondition( //Fog
            description: BaseText.WeatherCondition.fog,
            sfSymbolName: .same("cloud.fog.fill"),
            iconColor: .same([BaseColors.gray, BaseColors.secondary]),
            backgroundColorsDarkTheme: .single(BaseColors.overcastDark),
            backgroundColorsLightTheme: .single(BaseColors.overcastLight)),
        
        50: WeatherCondition( //Drizzle
            description: BaseText.WeatherCondition.drizzle,
            sfSymbolName: .same("cloud.drizzle.fill"),
            iconColor: .same([BaseColors.gray, BaseColors.cyan]),
            backgroundColorsDarkTheme: .single(BaseColors.rainDark),
            backgroundColorsLightTheme: .single(BaseColors.rainLight)),
        
        60: WeatherCondition( //Rain
            description: BaseText.WeatherCondition.rain,
            sfSymbolName: .same("cloud.rain.fill"),
            iconColor: .same([BaseColors.gray, BaseColors.blue]),
            backgroundColorsDarkTheme: .single(BaseColors.rainDark),
            backgroundColorsLightTheme: .single(BaseColors.rainLight)),
        
        65: WeatherCondition( //Heavy Rain
            description: BaseText.WeatherCondition.heavyRain,
            sfSymbolName: .same("cloud.heavyrain.fill"),
            iconColor: .same([BaseColors.gray, BaseColors.blue]),
            backgroundColorsDarkTheme: .single(BaseColors.rainDark),
            backgroundColorsLightTheme: .single(BaseColors.rainLight)),
        
        67: WeatherCondition( //Sleet
            description: BaseText.WeatherCondition.sleet,
            sfSymbolName: .same("cloud.sleet.fill"),
            iconColor: .same([BaseColors.gray, BaseColors.teal]),
            backgroundColorsDarkTheme: .single(BaseColors.snowDark),
            backgroundColorsLightTheme: .single(BaseColors.snowLight)),
        
        70: WeatherCondition( //Snow
            description: BaseText.WeatherCondition.snow,
            sfSymbolName: .same("snowflake"),
            iconColor: .same([BaseColors.cyan]),
            backgroundColorsDarkTheme: .single(BaseColors.snowDark),
            backgroundColorsLightTheme: .single(BaseColors.snowLight)),
        
        95: WeatherCondition( //Thunderstorm
            description: BaseText.WeatherCondition.thunderstorm,
            sfSymbolName: .same("cloud.bolt.rain.fill"),
            iconColor: .same([BaseColors.gray, BaseColors.yellow, BaseColors.blue]),
            backgroundColorsDarkTheme: .single(BaseColors.thunderstormDark),
            backgroundColorsLightTheme: .single(BaseColors.thunderstormLight))
    
    ]
}

extension Image {
    @ViewBuilder
    public func applyColors(_ colors: [Color]) -> some View {
        switch colors.count {
        case 0:
            self
        case 1:
            self.foregroundStyle(colors[0])
        case 2:
            self.foregroundStyle(colors[0], colors[1])
        default:
            self.foregroundStyle(colors[0], colors[1], colors[2])
        }
    }
}
