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

    var today: DailyForecastItem? {
        dailyItem(on: current.updatedAt)
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
