//
//  WeatherSummary.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

enum WeatherSummary {
    static func precipitation(for snapshot: CityWeatherSnapshot, now: Date) -> String {
        let calendar = snapshot.city.calendar
        let timeZone = snapshot.city.timeZone
        let restOfToday = snapshot.upcomingHourly(from: now, limit: 24)
            .filter { calendar.isDate($0.date, inSameDayAs: now) }
        let isWet: (HourlyForecastItem) -> Bool = {
            $0.condition.isPrecipitation && $0.precipitationChancePercent >= 50
        }

        if let currentHour = restOfToday.first, isWet(currentHour) {
            let noun = currentHour.condition.precipitationNoun
            guard let dryHour = restOfToday.first(where: { !isWet($0) }) else {
                return "\(noun) до конца дня"
            }
            return "\(noun) закончится около \(WeatherFormatter.time(dryHour.date, in: timeZone))"
        }

        if let wetHour = restOfToday.first(where: isWet) {
            return "\(wetHour.condition.precipitationNoun) начнётся около \(WeatherFormatter.time(wetHour.date, in: timeZone))"
        }

        return "Сегодня осадков не ожидается"
    }
}
