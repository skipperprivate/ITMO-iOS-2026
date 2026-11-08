import Foundation

enum ForecastMappingError: Error {
    case mismatchedArrays
    case missingValue
    case invalidDate(String)
    case invalidDayFlag(Int)
}

extension ForecastResponseDTO {
    func toForecast(for city: City, loadedAt: Date = Date()) throws -> WeatherForecast {
        guard hourly.time.count == hourly.temperature2m.count,
              hourly.time.count == hourly.weatherCode.count,
              hourly.time.count == hourly.isDay.count,
              daily.time.count == daily.temperature2mMin.count,
              daily.time.count == daily.temperature2mMax.count,
              daily.time.count == daily.weatherCode.count else {
            throw ForecastMappingError.mismatchedArrays
        }

        let zone = TimeZone(identifier: timezone)
            ?? TimeZone(secondsFromGMT: utcOffsetSeconds)
            ?? TimeZone(secondsFromGMT: 0)!
        let dateTime = formatter(format: "yyyy-MM-dd'T'HH:mm", timezone: zone)
        let dateTimeSeconds = formatter(format: "yyyy-MM-dd'T'HH:mm:ss", timezone: zone)
        let dayDate = formatter(format: "yyyy-MM-dd", timezone: zone)

        func parseTime(_ value: String) throws -> Date {
            guard let date = dateTime.date(from: value) ?? dateTimeSeconds.date(from: value) else {
                throw ForecastMappingError.invalidDate(value)
            }
            return date
        }
        func parseDay(_ value: String) throws -> Date {
            guard let date = dayDate.date(from: value) else {
                throw ForecastMappingError.invalidDate(value)
            }
            return date
        }
        func required<T>(_ value: T?) throws -> T {
            guard let value else { throw ForecastMappingError.missingValue }
            return value
        }
        func dayFlag(_ value: Int?) throws -> Bool {
            let flag = try required(value)
            guard flag == 0 || flag == 1 else { throw ForecastMappingError.invalidDayFlag(flag) }
            return flag == 1
        }

        let currentWeather = try CurrentWeather(
            date: parseTime(current.time), temperature: required(current.temperature2m),
            weatherCode: required(current.weatherCode), isDay: dayFlag(current.isDay)
        )
        let hours = try hourly.time.indices.map { index in
            try HourForecast(date: parseTime(hourly.time[index]),
                             temperature: required(hourly.temperature2m[index]),
                             weatherCode: required(hourly.weatherCode[index]),
                             isDay: dayFlag(hourly.isDay[index]))
        }
        let days = try daily.time.indices.map { index in
            try DayForecast(date: parseDay(daily.time[index]),
                            minimum: required(daily.temperature2mMin[index]),
                            maximum: required(daily.temperature2mMax[index]),
                            weatherCode: required(daily.weatherCode[index]))
        }
        return WeatherForecast(cityID: city.id, timezone: zone.identifier,
                               current: currentWeather, hourly: hours, daily: days,
                               loadedAt: loadedAt)
    }

    private func formatter(format: String, timezone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timezone
        formatter.dateFormat = format
        formatter.isLenient = false
        return formatter
    }
}
