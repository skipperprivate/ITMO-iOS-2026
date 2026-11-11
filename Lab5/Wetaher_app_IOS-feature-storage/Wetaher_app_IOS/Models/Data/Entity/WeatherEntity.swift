//
//  WeatherEntity.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

/// Последний успешный ответ сети по городу.
public struct WeatherEntity: Codable, Sendable {
    public let cityID: Int
    public let cityName: String
    public let country: String
    public let latitude: Double
    public let longitude: Double
    public let timezone: String
    public let savedAt: Date
    public let current: CurrentWeatherEntity
    public let hourly: [HourlyWeatherEntity]
    public let daily: [DailyWeatherEntity]
}
