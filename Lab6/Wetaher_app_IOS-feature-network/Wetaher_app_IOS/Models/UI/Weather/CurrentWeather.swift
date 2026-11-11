//
//  CurrentWeather.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 04.10.2026.
//

import Foundation

public struct CurrentWeather: Equatable, Hashable {
    public let date: String
    public let time: String
    public let temperature: Double
    public let apparentTemp: Double
    public let weatherCondition: WeatherCondition
    public let isDay: Bool
    public let windSpeed: Double
    public let windDirection: String
    public let windGusts: Double
    public let relativeHumidity: Int
    public let dewPoint: Double
    public let pressure: Double
    public let pressureStatus: String
    public let pressureMmHg: Int
    public let visibility: Double
    public let visibilityStatus: String
}
