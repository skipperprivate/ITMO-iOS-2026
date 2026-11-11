//
//  CurrentWeatherRecord.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation
import SwiftData

// Таблица `current_weather`: текущая погода для записи прогноза (1:1 от `weather`)
@Model
final class CurrentWeatherRecord {
    var time: String
    var temperature: Double
    var apparentTemperature: Double
    var weatherCode: Int
    var isDay: Bool
    var windSpeed: Double
    var windDirection: Int
    var windGusts: Double
    var relativeHumidity: Int
    var dewPoint: Double
    var pressureMsl: Double
    var visibility: Double

    var weather: WeatherRecord?

    init(
        time: String,
        temperature: Double,
        apparentTemperature: Double,
        weatherCode: Int,
        isDay: Bool,
        windSpeed: Double,
        windDirection: Int,
        windGusts: Double,
        relativeHumidity: Int,
        dewPoint: Double,
        pressureMsl: Double,
        visibility: Double
    ) {
        self.time = time
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.weatherCode = weatherCode
        self.isDay = isDay
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.windGusts = windGusts
        self.relativeHumidity = relativeHumidity
        self.dewPoint = dewPoint
        self.pressureMsl = pressureMsl
        self.visibility = visibility
    }

    convenience init(entity: CurrentWeatherEntity) {
        self.init(
            time: entity.time,
            temperature: entity.temperature,
            apparentTemperature: entity.apparentTemperature,
            weatherCode: entity.weatherCode,
            isDay: entity.isDay,
            windSpeed: entity.windSpeed,
            windDirection: entity.windDirection,
            windGusts: entity.windGusts,
            relativeHumidity: entity.relativeHumidity,
            dewPoint: entity.dewPoint,
            pressureMsl: entity.pressureMsl,
            visibility: entity.visibility
        )
    }

    var currentWeatherEntity: CurrentWeatherEntity {
        CurrentWeatherEntity(
            time: time,
            temperature: temperature,
            apparentTemperature: apparentTemperature,
            weatherCode: weatherCode,
            isDay: isDay,
            windSpeed: windSpeed,
            windDirection: windDirection,
            windGusts: windGusts,
            relativeHumidity: relativeHumidity,
            dewPoint: dewPoint,
            pressureMsl: pressureMsl,
            visibility: visibility
        )
    }
}
