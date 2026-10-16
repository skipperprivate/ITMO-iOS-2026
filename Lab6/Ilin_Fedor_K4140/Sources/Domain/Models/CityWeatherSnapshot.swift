import Foundation

nonisolated struct CityWeatherSnapshot: Hashable, Codable, Sendable {
    let city: City
    let current: CurrentWeather
    let hourly: [HourlyForecastItem]
    let daily: [DailyForecastItem]
    let fetchedAt: Date

    func today(now: Date) -> DailyForecastItem? {
        dailyItem(on: now)
    }

    func upcomingDaily(from now: Date) -> [DailyForecastItem] {
        let startOfToday = city.calendar.startOfDay(for: now)
        return daily.filter { $0.date >= startOfToday }
    }

    func with(city: City) -> CityWeatherSnapshot {
        CityWeatherSnapshot(city: city, current: current, hourly: hourly, daily: daily, fetchedAt: fetchedAt)
    }

    func hourlyItems(on date: Date) -> [HourlyForecastItem] {
        let calendar = city.calendar
        return hourly.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func dailyItem(on date: Date) -> DailyForecastItem? {
        let calendar = city.calendar
        return daily.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func upcomingHourly(from now: Date, limit: Int = 24) -> [HourlyForecastItem] {
        let startOfHour = city.calendar.dateInterval(of: .hour, for: now)?.start ?? now
        return Array(hourly.filter { $0.date >= startOfHour }.prefix(limit))
    }
}
