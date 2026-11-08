//
//  OpenMeteoMapper.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

nonisolated enum OpenMeteoMappingError: Error, Equatable, Sendable {
    case missingValue(String)
    case seriesLengthMismatch(String)
    case emptyForecast
}

// DTO → domain. Policy for nulls: a value the screen can't do without fails the mapping,
// a single missing hour or day is dropped, secondary metrics fall back to a neutral value.
nonisolated enum OpenMeteoMapper {
    static func snapshot(from dto: OpenMeteoForecastDTO, city: City) throws -> CityWeatherSnapshot {
        let daily = try dailyItems(from: dto.daily, calendar: city.calendar)
        let hourly = try hourlyItems(from: dto.hourly, daily: daily)
        guard !daily.isEmpty, !hourly.isEmpty else { throw OpenMeteoMappingError.emptyForecast }
        let current = try currentWeather(from: dto.current, daily: daily)
        return CityWeatherSnapshot(city: city, current: current, hourly: hourly, daily: daily)
    }

    static func cities(from dto: OpenMeteoGeocodingDTO) -> [City] {
        var seen = Set<Int>()
        return (dto.results ?? []).compactMap { location in
            guard seen.insert(location.id).inserted else { return nil }
            return city(from: location)
        }
    }

    // MARK: - Forecast

    private static func currentWeather(from dto: OpenMeteoForecastDTO.Current, daily: [DailyForecastItem]) throws -> CurrentWeather {
        let updatedAt = Date(timeIntervalSince1970: dto.time)
        let temperature = try required(dto.temperature, "current.temperature_2m")
        let windSpeed = try required(dto.windSpeed, "current.wind_speed_10m")
        return CurrentWeather(
            temperatureCelsius: temperature,
            feelsLikeCelsius: dto.apparentTemperature ?? temperature,
            condition: WeatherCondition(wmoCode: try required(dto.weatherCode, "current.weather_code")),
            isDaytime: dto.isDay.map { $0 != 0 } ?? isDaytime(at: updatedAt, daily: daily),
            windSpeedKmh: windSpeed,
            windGustsKmh: max(dto.windGusts ?? windSpeed, windSpeed),
            windDirectionDegrees: try required(dto.windDirection, "current.wind_direction_10m"),
            humidityPercent: percent(try required(dto.relativeHumidity, "current.relative_humidity_2m")),
            pressureHPa: try required(dto.pressureMSL, "current.pressure_msl"),
            uvIndex: max(dto.uvIndex ?? 0, 0),
            visibilityKm: try required(dto.visibility, "current.visibility") / 1000,
            updatedAt: updatedAt
        )
    }

    private static func hourlyItems(from dto: OpenMeteoForecastDTO.Hourly, daily: [DailyForecastItem]) throws -> [HourlyForecastItem] {
        try checkLengths("hourly", dto.time.count, [
            dto.temperature.count, dto.weatherCode.count, dto.isDay.count, dto.precipitationProbability.count
        ])
        return dto.time.indices.compactMap { index in
            guard let temperature = dto.temperature[index], let code = dto.weatherCode[index] else { return nil }
            let date = Date(timeIntervalSince1970: dto.time[index])
            return HourlyForecastItem(
                date: date,
                temperatureCelsius: temperature,
                condition: WeatherCondition(wmoCode: code),
                isDaytime: dto.isDay[index].map { $0 != 0 } ?? isDaytime(at: date, daily: daily),
                precipitationChancePercent: percent(dto.precipitationProbability[index] ?? 0)
            )
        }
    }

    private static func dailyItems(from dto: OpenMeteoForecastDTO.Daily, calendar: Calendar) throws -> [DailyForecastItem] {
        try checkLengths("daily", dto.time.count, [
            dto.weatherCode.count, dto.temperatureMax.count, dto.temperatureMin.count,
            dto.precipitationProbabilityMax.count, dto.precipitationSum.count, dto.windSpeedMax.count,
            dto.uvIndexMax.count, dto.sunrise.count, dto.sunset.count
        ])
        return dto.time.indices.compactMap { index in
            guard let code = dto.weatherCode[index],
                  let maxTemperature = dto.temperatureMax[index],
                  let minTemperature = dto.temperatureMin[index] else { return nil }
            let date = localMidnight(near: Date(timeIntervalSince1970: dto.time[index]), calendar: calendar)
            // Polar night comes as sunrise == sunset == midnight; the same stands in for a missing value.
            let sunrise = dto.sunrise[index].map(Date.init(timeIntervalSince1970:)) ?? date
            let sunset = dto.sunset[index].map(Date.init(timeIntervalSince1970:)) ?? sunrise
            return DailyForecastItem(
                date: date,
                minTemperatureCelsius: min(minTemperature, maxTemperature),
                maxTemperatureCelsius: max(minTemperature, maxTemperature),
                condition: WeatherCondition(wmoCode: code),
                precipitationChancePercent: percent(dto.precipitationProbabilityMax[index] ?? 0),
                precipitationSumMm: max(dto.precipitationSum[index] ?? 0, 0),
                windSpeedMaxKmh: max(dto.windSpeedMax[index] ?? 0, 0),
                uvIndexMax: max(dto.uvIndexMax[index] ?? 0, 0),
                sunrise: sunrise,
                sunset: max(sunset, sunrise)
            )
        }
    }

    // The server applies one UTC offset (today's) to the whole range, so after a DST switch
    // "midnight" arrives as 01:00 or as 23:00 of the previous day. Snap to the nearest real midnight.
    private static func localMidnight(near date: Date, calendar: Calendar) -> Date {
        calendar.startOfDay(for: date.addingTimeInterval(12 * 3600))
    }

    // Used only when is_day is null; polar day spans the whole day, polar night is empty.
    private static func isDaytime(at date: Date, daily: [DailyForecastItem]) -> Bool {
        guard let day = daily.last(where: { $0.date <= date }) else { return false }
        return date >= day.sunrise && date < day.sunset
    }

    // MARK: - Geocoding

    private static func city(from location: OpenMeteoGeocodingDTO.Location) -> City? {
        // Without a valid zone the forecast days can't be aligned with the city's calendar.
        guard let zone = location.timezone, TimeZone(identifier: zone) != nil,
              (-90...90).contains(location.latitude), (-180...180).contains(location.longitude) else { return nil }
        let name = location.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }
        // For federal cities admin1 repeats the name ("Москва, Москва").
        let region = location.admin1.flatMap { $0.caseInsensitiveCompare(name) == .orderedSame ? nil : $0 } ?? ""
        return City(
            id: String(location.id),
            name: name,
            region: region,
            country: location.country ?? location.countryCode ?? "",
            latitude: location.latitude,
            longitude: location.longitude,
            timeZoneIdentifier: zone
        )
    }

    // MARK: - Helpers

    private static func required<Value>(_ value: Value?, _ field: String) throws -> Value {
        guard let value else { throw OpenMeteoMappingError.missingValue(field) }
        return value
    }

    private static func checkLengths(_ series: String, _ expected: Int, _ counts: [Int]) throws {
        guard counts.allSatisfy({ $0 == expected }) else {
            throw OpenMeteoMappingError.seriesLengthMismatch(series)
        }
    }

    private static func percent(_ value: Double) -> Int {
        Int(min(max(value, 0), 100).rounded())
    }
}
