//
//  DailyWeather.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 04.10.2026.
//

import Foundation

public struct DailyWeather: Equatable, Hashable {
    let date: String
    let day: String //Научится определять день недели!
    let tempMax: Double
    let tempMin: Double
    let weatherCondition: WeatherCondition
    let uVIndex: Double
    let sunrise: String
    let sunset: String
    let precipProbabilityMean: Int
}
