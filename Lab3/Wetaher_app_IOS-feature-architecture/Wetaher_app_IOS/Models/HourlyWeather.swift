//
//  HourlyWeather.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 04.10.2026.
//

import Foundation

public struct HourlyWeather: Equatable, Hashable {
    let hour: String
    let temperature: Double
    let weatherCondition: WeatherCondition
    let isDay: Bool
    let precipProb: Int
}
