//
//  DailyWeatherEntity.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

public struct DailyWeatherEntity: Codable, Hashable, Sendable {
    public let time: String
    public let temperatureMax: Double
    public let temperatureMin: Double
    public let weatherCode: Int
    public let uvIndexMax: Double
    public let sunrise: String
    public let sunset: String
    public let precipitationProbabilityMean: Int
}
