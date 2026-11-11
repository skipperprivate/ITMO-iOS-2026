//
//  CurrentWeather.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 04.10.2026.
//

import Foundation

public struct CurrentWeather: Equatable, Hashable{
    let dateTime: String //Потом подумаю как это конвертировать в Date (если это вообще потребуется)
    let temperature: Double
    let apparentTemp: Double
    let weatherCondition: WeatherCondition
    let isDay: Bool
    let windSpeed: Double
    let windDirection: Int
    let windGusts: Double
    let relativeHumidity: Int
    let dewPoint: Double
    let pressure: Double
    let visibility: Double
}
