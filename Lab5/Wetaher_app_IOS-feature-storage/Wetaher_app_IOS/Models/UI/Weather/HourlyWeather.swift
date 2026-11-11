//
//  HourlyWeather.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 04.10.2026.
//

import Foundation

public struct HourlyWeather: Equatable, Hashable {
    public let hour: String
    public let temperature: Double
    public let weatherCondition: WeatherCondition
    public let isDay: Bool
    public let precipProb: Int
}
