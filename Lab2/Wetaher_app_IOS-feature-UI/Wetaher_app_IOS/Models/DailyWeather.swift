//
//  DailyWeather.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 04.10.2026.
//

import Foundation

public struct DailyWeather: Equatable, Hashable {
    public let date: String
    public let day: String //Научится определять день недели!
    public let tempMax: Double
    public let tempMin: Double
    public let weatherCondition: WeatherCondition
    public let uVIndex: Double
    public let sunrise: String
    public let sunset: String
    public let precipProbabilityMean: Int
}
