//
//  DailyWeatherRecord.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation
import SwiftData

// Таблица `daily_weather`: один день прогноза (1:N от `weather`)
@Model
final class DailyWeatherRecord {
    var sortIndex: Int
    var time: String
    var temperatureMax: Double
    var temperatureMin: Double
    var weatherCode: Int
    var uvIndexMax: Double
    var sunrise: String
    var sunset: String
    var precipitationProbabilityMean: Int

    var weather: WeatherRecord?

    init(
        sortIndex: Int,
        time: String,
        temperatureMax: Double,
        temperatureMin: Double,
        weatherCode: Int,
        uvIndexMax: Double,
        sunrise: String,
        sunset: String,
        precipitationProbabilityMean: Int
    ) {
        self.sortIndex = sortIndex
        self.time = time
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.weatherCode = weatherCode
        self.uvIndexMax = uvIndexMax
        self.sunrise = sunrise
        self.sunset = sunset
        self.precipitationProbabilityMean = precipitationProbabilityMean
    }

    convenience init(entity: DailyWeatherEntity, sortIndex: Int) {
        self.init(
            sortIndex: sortIndex,
            time: entity.time,
            temperatureMax: entity.temperatureMax,
            temperatureMin: entity.temperatureMin,
            weatherCode: entity.weatherCode,
            uvIndexMax: entity.uvIndexMax,
            sunrise: entity.sunrise,
            sunset: entity.sunset,
            precipitationProbabilityMean: entity.precipitationProbabilityMean
        )
    }

    var dailyWeatherEntity: DailyWeatherEntity {
        DailyWeatherEntity(
            time: time,
            temperatureMax: temperatureMax,
            temperatureMin: temperatureMin,
            weatherCode: weatherCode,
            uvIndexMax: uvIndexMax,
            sunrise: sunrise,
            sunset: sunset,
            precipitationProbabilityMean: precipitationProbabilityMean
        )
    }
}
