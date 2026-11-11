//
//  DailyForecastItem.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

nonisolated struct DailyForecastItem: Identifiable, Hashable, Codable, Sendable {
    var id: Date { date }
    let date: Date
    let minTemperatureCelsius: Double
    let maxTemperatureCelsius: Double
    let condition: WeatherCondition
    let precipitationChancePercent: Int
    let precipitationSumMm: Double
    let windSpeedMaxKmh: Double
    let uvIndexMax: Double
    let sunrise: Date
    let sunset: Date
}
