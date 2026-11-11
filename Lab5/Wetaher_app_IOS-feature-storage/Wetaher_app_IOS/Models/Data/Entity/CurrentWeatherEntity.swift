//
//  CurrentWeatherEntity.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

public struct CurrentWeatherEntity: Codable, Hashable, Sendable {
    public let time: String
    public let temperature: Double
    public let apparentTemperature: Double
    public let weatherCode: Int
    public let isDay: Bool
    public let windSpeed: Double
    public let windDirection: Int
    public let windGusts: Double
    public let relativeHumidity: Int
    public let dewPoint: Double
    public let pressureMsl: Double
    public let visibility: Double
}
