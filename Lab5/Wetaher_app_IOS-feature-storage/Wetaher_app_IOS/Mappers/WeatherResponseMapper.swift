//
//  WeatherResponseMapper.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 18.10.2026.
//

import Foundation

extension WeatherResponse {
    func toEntity(city: City, savedAt: Date = Date()) -> WeatherEntity {
        WeatherEntity(
            cityID: city.id,
            cityName: city.name,
            country: city.country,
            latitude: city.latitude,
            longitude: city.longitude,
            timezone: city.timezone,
            savedAt: savedAt,
            current: current.toEntity(),
            hourly: hourly.toEntity(currentTime: current.time),
            daily: daily.toEntity()
        )
    }
}

extension CurrentWeatherResponse {
    func toEntity() -> CurrentWeatherEntity {
        CurrentWeatherEntity(
            time: time,
            temperature: temperature2m,
            apparentTemperature: apparentTemperature,
            weatherCode: weatherCode,
            isDay: isDay != 0,
            windSpeed: windSpeed10m,
            windDirection: windDirection10m,
            windGusts: windGusts10m,
            relativeHumidity: relativeHumidity2m,
            dewPoint: dewPoint2m,
            pressureMsl: pressureMsl,
            visibility: visibility
        )
    }
}

extension HourlyWeatherResponse {
    func toEntity(currentTime: String) -> [HourlyWeatherEntity] {
        let available = min(
            time.count,
            temperature2m.count,
            weatherCode.count,
            isDay.count,
            precipitationProbability.count
        )
        guard available > 0 else { return [] }

        let start = min(Self.hour(from: currentTime), available)
        let end = min(start + 24, available)
        guard start < end else { return [] }

        return (start..<end).map { index in
            HourlyWeatherEntity(
                time: time[index],
                temperature: temperature2m[index],
                weatherCode: weatherCode[index],
                isDay: isDay[index] != 0,
                precipitationProbability: precipitationProbability[index]
            )
        }
    }

    /// Час из строки формата `yyyy-MM-dd'T'HH:mm` (при `timezone=auto` время уже местное для города).
    private static func hour(from dateString: String) -> Int {
        guard let separator = dateString.firstIndex(of: "T") else { return 0 }
        let timePart = dateString[dateString.index(after: separator)...]
        return Int(timePart.prefix(2)) ?? 0
    }
}

extension DailyWeatherResponse {
    func toEntity() -> [DailyWeatherEntity] {
        let available = min(
            time.count,
            temperature2mMax.count,
            temperature2mMin.count,
            weatherCode.count,
            uVIndexMax.count,
            sunrise.count,
            sunset.count,
            precipitationProbabilityMean.count
        )
        guard available > 0 else { return [] }

        return (0..<available).map { index in
            DailyWeatherEntity(
                time: time[index],
                temperatureMax: temperature2mMax[index],
                temperatureMin: temperature2mMin[index],
                weatherCode: weatherCode[index],
                uvIndexMax: uVIndexMax[index],
                sunrise: sunrise[index],
                sunset: sunset[index],
                precipitationProbabilityMean: precipitationProbabilityMean[index]
            )
        }
    }
}
