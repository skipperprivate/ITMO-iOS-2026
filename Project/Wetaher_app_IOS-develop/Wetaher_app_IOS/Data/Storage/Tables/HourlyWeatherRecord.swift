//
//  HourlyWeatherRecord.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation
import SwiftData

// Таблица `hourly_weather`: один час прогноза (1:N от `weather`)
@Model
final class HourlyWeatherRecord {
    var sortIndex: Int
    var time: String
    var temperature: Double
    var weatherCode: Int
    var isDay: Bool
    var precipitationProbability: Int

    var weather: WeatherRecord?

    init(
        sortIndex: Int,
        time: String,
        temperature: Double,
        weatherCode: Int,
        isDay: Bool,
        precipitationProbability: Int
    ) {
        self.sortIndex = sortIndex
        self.time = time
        self.temperature = temperature
        self.weatherCode = weatherCode
        self.isDay = isDay
        self.precipitationProbability = precipitationProbability
    }

    convenience init(entity: HourlyWeatherEntity, sortIndex: Int) {
        self.init(
            sortIndex: sortIndex,
            time: entity.time,
            temperature: entity.temperature,
            weatherCode: entity.weatherCode,
            isDay: entity.isDay,
            precipitationProbability: entity.precipitationProbability
        )
    }

    var hourlyWeatherEntity: HourlyWeatherEntity {
        HourlyWeatherEntity(
            time: time,
            temperature: temperature,
            weatherCode: weatherCode,
            isDay: isDay,
            precipitationProbability: precipitationProbability
        )
    }
}
