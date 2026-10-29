#if DEBUG
import Foundation

nonisolated struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: String) {
        state = seed.utf8.reduce(UInt64(1469598103934665603)) { partial, byte in
            (partial ^ UInt64(byte)) &* 1099511628211
        }
        if state == 0 { state = 0xdeadbeef }
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

nonisolated enum MockData {
    static let allCities: [City] = [
        City(
            id: "moscow", name: "Москва", region: "Московская область", country: "Россия",
            latitude: 55.7558, longitude: 37.6173, timeZoneIdentifier: "Europe/Moscow"
        ),
        City(
            id: "spb", name: "Санкт-Петербург", region: "Ленинградская область", country: "Россия",
            latitude: 59.9311, longitude: 30.3609, timeZoneIdentifier: "Europe/Moscow"
        ),
        City(
            id: "sochi", name: "Сочи", region: "Краснодарский край", country: "Россия",
            latitude: 43.6028, longitude: 39.7342, timeZoneIdentifier: "Europe/Moscow"
        ),
        City(
            id: "kazan", name: "Казань", region: "Татарстан", country: "Россия",
            latitude: 55.8304, longitude: 49.0661, timeZoneIdentifier: "Europe/Moscow"
        ),
        City(
            id: "novosibirsk", name: "Новосибирск", region: "Новосибирская область", country: "Россия",
            latitude: 55.0084, longitude: 82.9357, timeZoneIdentifier: "Asia/Novosibirsk"
        ),
        City(
            id: "ekaterinburg", name: "Екатеринбург", region: "Свердловская область", country: "Россия",
            latitude: 56.8389, longitude: 60.6057, timeZoneIdentifier: "Asia/Yekaterinburg"
        ),
        City(
            id: "vladivostok", name: "Владивосток", region: "Приморский край", country: "Россия",
            latitude: 43.1332, longitude: 131.9113, timeZoneIdentifier: "Asia/Vladivostok"
        ),
        City(
            id: "kaliningrad", name: "Калининград", region: "Калининградская область", country: "Россия",
            latitude: 54.7104, longitude: 20.4522, timeZoneIdentifier: "Europe/Kaliningrad"
        ),
        City(
            id: "krasnoyarsk", name: "Красноярск", region: "Красноярский край", country: "Россия",
            latitude: 56.0184, longitude: 92.8672, timeZoneIdentifier: "Asia/Krasnoyarsk"
        ),
        City(
            id: "ufa", name: "Уфа", region: "Башкортостан", country: "Россия",
            latitude: 54.7388, longitude: 55.9721, timeZoneIdentifier: "Asia/Yekaterinburg"
        )
    ]

    private static let dayCount = 10
    private static let conditions: [WeatherCondition] = [
        .clearSky, .clearSky, .clearSky, .mostlyClear, .mostlyClear, .mostlyClear,
        .partlyCloudy, .partlyCloudy, .partlyCloudy, .cloudy, .cloudy, .fog,
        .drizzle, .rain, .rainShowers, .thunderstorm
    ]

    static func snapshot(for city: City, now: Date = Date()) -> CityWeatherSnapshot {
        var rng = SeededGenerator(seed: city.id)
        let calendar = city.calendar
        let startOfToday = calendar.startOfDay(for: now)

        let baseTemp = Double.random(in: -6...22, using: &rng)
        let dayDrift = (0..<dayCount).map { _ in Double.random(in: -4...4, using: &rng) }
        let dayAmplitude = (0..<dayCount).map { _ in Double.random(in: 2.5...7, using: &rng) }
        let spells = (0..<(dayCount * 4)).map { _ in conditions[Int(rng.next() % UInt64(conditions.count))] }

        let days: [Date] = (0..<dayCount).map { calendar.date(byAdding: .day, value: $0, to: startOfToday) ?? startOfToday }
        let sunTimes: [(sunrise: Date, sunset: Date)] = days.enumerated().map { index, day in
            let sunrise = calendar.date(bySettingHour: 6, minute: 40 + index, second: 0, of: day) ?? day
            let sunset = calendar.date(bySettingHour: 19, minute: 20 - index, second: 0, of: day) ?? day
            return (sunrise, sunset)
        }

        let hourly: [HourlyForecastItem] = (0..<(dayCount * 24)).map { offset in
            let date = calendar.date(byAdding: .hour, value: offset, to: startOfToday) ?? startOfToday
            let dayIndex = offset / 24
            let hour = Double(offset % 24)
            let diurnal = dayAmplitude[dayIndex] * sin((hour - 9) / 24 * 2 * .pi)
            let temperature = baseTemp + dayDrift[dayIndex] + diurnal
            let spell = spells[offset / 6]
            let condition: WeatherCondition = temperature < 1 && spell.isPrecipitation ? .snow : spell
            let chance = condition.isPrecipitation
                ? Int.random(in: 55...95, using: &rng)
                : Int.random(in: 0...25, using: &rng)
            let sun = sunTimes[dayIndex]
            return HourlyForecastItem(
                date: date,
                temperatureCelsius: temperature,
                condition: condition,
                isDaytime: date >= sun.sunrise && date < sun.sunset,
                precipitationChancePercent: chance
            )
        }

        let daily = dailyForecasts(days: days, hourly: hourly, sunTimes: sunTimes, baseTemp: baseTemp, using: &rng)
        let current = currentWeather(hourly: hourly, daily: daily, calendar: calendar, now: now, using: &rng)

        return CityWeatherSnapshot(city: city, current: current, hourly: hourly, daily: daily, fetchedAt: now)
    }

    private static func dailyForecasts(
        days: [Date],
        hourly: [HourlyForecastItem],
        sunTimes: [(sunrise: Date, sunset: Date)],
        baseTemp: Double,
        using rng: inout SeededGenerator
    ) -> [DailyForecastItem] {
        days.enumerated().map { index, day in
            let hours = hourly[(index * 24)..<((index + 1) * 24)]
            let temperatures = hours.map(\.temperatureCelsius)
            let wetHours = hours.filter { $0.condition.isPrecipitation }
            let dominant = wetHours.count >= 12
                ? wetHours[wetHours.startIndex].condition
                : hours[hours.startIndex + 13].condition
            let relevantHours = dominant.isPrecipitation ? Array(hours) : hours.filter { !$0.condition.isPrecipitation }
            return DailyForecastItem(
                date: day,
                minTemperatureCelsius: temperatures.min() ?? baseTemp,
                maxTemperatureCelsius: temperatures.max() ?? baseTemp,
                condition: dominant,
                precipitationChancePercent: relevantHours.map(\.precipitationChancePercent).max() ?? 0,
                precipitationSumMm: Double(wetHours.count) * Double.random(in: 0.2...1.4, using: &rng),
                windSpeedMaxKmh: Double.random(in: 8...42, using: &rng),
                uvIndexMax: dominant.isPrecipitation ? Double.random(in: 0...2, using: &rng) : Double.random(in: 2...7, using: &rng),
                sunrise: sunTimes[index].sunrise,
                sunset: sunTimes[index].sunset
            )
        }
    }

    private static func currentWeather(
        hourly: [HourlyForecastItem],
        daily: [DailyForecastItem],
        calendar: Calendar,
        now: Date,
        using rng: inout SeededGenerator
    ) -> CurrentWeather {
        let currentHour = hourly.first { calendar.isDate($0.date, equalTo: now, toGranularity: .hour) } ?? hourly[0]
        let wind = Double.random(in: 4...26, using: &rng)
        return CurrentWeather(
            temperatureCelsius: currentHour.temperatureCelsius,
            feelsLikeCelsius: currentHour.temperatureCelsius - wind / 8,
            condition: currentHour.condition,
            isDaytime: currentHour.isDaytime,
            windSpeedKmh: wind,
            windGustsKmh: wind * Double.random(in: 1.3...1.8, using: &rng),
            windDirectionDegrees: Double.random(in: 0..<360, using: &rng),
            humidityPercent: Int.random(in: 35...95, using: &rng),
            pressureHPa: Double.random(in: 990...1030, using: &rng),
            uvIndex: currentHour.isDaytime ? (daily.first?.uvIndexMax ?? 0) * 0.7 : 0,
            visibilityKm: currentHour.condition == .fog ? Double.random(in: 0.3...2, using: &rng) : Double.random(in: 8...24, using: &rng),
            updatedAt: now
        )
    }
}
#endif
