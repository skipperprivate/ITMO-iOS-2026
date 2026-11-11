//
//  HourlyWeatherEntity.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

public struct HourlyWeatherEntity: Codable, Hashable, Sendable {
    public let time: String
    public let temperature: Double
    public let weatherCode: Int
    public let isDay: Bool
    public let precipitationProbability: Int
}
