//
//  WeatherEntityMapper.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation

extension WeatherEntity {
    /// Entity → UI.
    func toUI() -> ForecastUI {
        let currentTime = current.time

        return ForecastUI(
            city: City(
                id: cityID,
                name: cityName,
                country: country,
                latitude: latitude,
                longitude: longitude,
                timezone: timezone,
                localTime: CityUIHelper.localTime(timeZone: timezone)
            ),
            currentWeather: current.toUI(),
            hourlyWeather: hourly.enumerated().map { index, item in
                item.toUI(isCurrentHour: index == 0)
            },
            dailyWeather: daily.enumerated().map { index, item in
                item.toUI(currentTime: currentTime, index: index)
            }
        )
    }
}

extension CurrentWeatherEntity {
    func toUI() -> CurrentWeather {
        let visibilityInKm = WeatherUIHelper.visibility(visibility)

        return CurrentWeather(
            date: WeatherUIHelper.formatDateString(time),
            time: WeatherUIHelper.formatTimeString(time),
            temperature: temperature,
            apparentTemp: apparentTemperature,
            weatherCondition: WeatherCondition.condition(for: weatherCode),
            isDay: isDay,
            windSpeed: windSpeed,
            windDirection: WeatherUIHelper.degreesToDirection(windDirection),
            windGusts: windGusts,
            relativeHumidity: relativeHumidity,
            dewPoint: dewPoint,
            pressure: pressureMsl,
            pressureStatus: WeatherUIHelper.pressureStatus(for: pressureMsl),
            pressureMmHg: WeatherUIHelper.pressureMmHg(pressureMsl),
            visibility: visibilityInKm,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: visibilityInKm)
        )
    }
}

extension HourlyWeatherEntity {
    func toUI(isCurrentHour: Bool) -> HourlyWeather {
        HourlyWeather(
            hour: isCurrentHour ? "Сейчас" : WeatherUIHelper.formatTimeString(time),
            temperature: temperature,
            weatherCondition: WeatherCondition.condition(for: weatherCode),
            isDay: isDay,
            precipProb: precipitationProbability
        )
    }
}

extension DailyWeatherEntity {
    func toUI(currentTime: String, index: Int) -> DailyWeather {
        DailyWeather(
            date: WeatherUIHelper.formatDateLocalizedString(time),
            day: WeatherUIHelper.formatDayOfWeekString(time, currentDT: currentTime, index: index),
            tempMax: temperatureMax,
            tempMin: temperatureMin,
            weatherCondition: WeatherCondition.condition(for: weatherCode),
            uVIndex: uvIndexMax,
            uvStatus: WeatherUIHelper.uvStatus(for: uvIndexMax),
            sunrise: WeatherUIHelper.formatTimeString(sunrise),
            sunset: WeatherUIHelper.formatTimeString(sunset),
            precipProbabilityMean: precipitationProbabilityMean
        )
    }
}

extension WeatherCondition {
    static func condition(for weatherCode: Int) -> WeatherCondition {
        weatherConditionsDict[weatherCode] ?? defaultWeatherCondition
    }
}
