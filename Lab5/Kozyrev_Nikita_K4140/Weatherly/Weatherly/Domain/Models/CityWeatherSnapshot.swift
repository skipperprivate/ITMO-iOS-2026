//
//  CityWeatherSnapshot.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

nonisolated struct CityWeatherSnapshot: Hashable, Codable, Sendable {
    let city: City
    let current: CurrentWeather
    let hourly: [HourlyForecastItem]
    let daily: [DailyForecastItem]
    // When the app received it (device clock); a cached snapshot can be hours old.
    let fetchedAt: Date

    // By the clock, not by `current.updatedAt`: a cached snapshot may be from yesterday.
    func today(now: Date) -> DailyForecastItem? {
        dailyItem(on: now)
    }

    // Days already over drop out of a cached forecast.
    func upcomingDaily(from now: Date) -> [DailyForecastItem] {
        let startOfToday = city.calendar.startOfDay(for: now)
        return daily.filter { $0.date >= startOfToday }
    }

    // A record cached for these coordinates can come back under another City with the same location.
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

    // From the hour containing now (APIs return the whole day from 00:00).
    func upcomingHourly(from now: Date, limit: Int = 24) -> [HourlyForecastItem] {
        let startOfHour = city.calendar.dateInterval(of: .hour, for: now)?.start ?? now
        return Array(hourly.filter { $0.date >= startOfHour }.prefix(limit))
    }
}
