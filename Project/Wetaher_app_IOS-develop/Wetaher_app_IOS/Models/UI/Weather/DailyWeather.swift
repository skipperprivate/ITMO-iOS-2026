//
//  DailyWeather.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 04.10.2026.
//

import Foundation
import SwiftUI

public struct DailyWeather: Equatable, Hashable {
    public let date: String
    public let day: String
    public let tempMax: Double
    public let tempMin: Double
    public let weatherCondition: WeatherCondition
    public let uVIndex: Double
    public let uvStatus: UVStatus
    public let sunrise: String
    public let sunset: String
    public let precipProbabilityMean: Int
}
