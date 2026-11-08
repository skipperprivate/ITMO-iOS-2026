import Foundation

struct WeatherForecast: Equatable, Sendable {
    let cityID: Int
    let timezone: String
    let current: CurrentWeather
    let hourly: [HourForecast]
    let daily: [DayForecast]
    let loadedAt: Date

    var displayTimeZone: TimeZone {
        TimeZone(identifier: timezone) ?? TimeZone(secondsFromGMT: 0)!
    }
}
