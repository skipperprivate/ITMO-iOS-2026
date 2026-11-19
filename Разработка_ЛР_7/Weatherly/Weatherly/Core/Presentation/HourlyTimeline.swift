//
//  HourlyTimeline.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

enum HourlyTimelineEntry: Identifiable, Hashable {
    case hour(HourlyForecastItem, isHighlighted: Bool)
    case sunrise(Date)
    case sunset(Date)

    var date: Date {
        switch self {
        case .hour(let item, _): item.date
        case .sunrise(let date), .sunset(let date): date
        }
    }

    var id: String {
        switch self {
        case .hour(let item, _): "hour-\(item.date.timeIntervalSince1970)"
        case .sunrise(let date): "sunrise-\(date.timeIntervalSince1970)"
        case .sunset(let date): "sunset-\(date.timeIntervalSince1970)"
        }
    }
}

// Merges hours with the sunrise/sunset moments inside the covered range.
enum HourlyTimeline {
    // `current`: the "now" tile shows the same reading as the hero above it; the hourly value
    // is for the top of the hour and would disagree with it by a degree or a different sky.
    static func entries(
        hours: [HourlyForecastItem],
        days: [DailyForecastItem],
        highlightFirst: Bool,
        current: CurrentWeather? = nil
    ) -> [HourlyTimelineEntry] {
        guard let first = hours.first, let last = hours.last else { return [] }
        let rangeEnd = last.date.addingTimeInterval(3600)

        let hourEntries = hours.enumerated().map { index, item in
            let isNow = highlightFirst && index == 0
            let shown = isNow ? current.map { item.replacingReading(with: $0) } ?? item : item
            return HourlyTimelineEntry.hour(shown, isHighlighted: isNow)
        }
        let sunEntries = days
            .flatMap { [HourlyTimelineEntry.sunrise($0.sunrise), .sunset($0.sunset)] }
            .filter { $0.date > first.date && $0.date < rangeEnd }

        return (hourEntries + sunEntries).sorted { $0.date < $1.date }
    }
}

private extension HourlyForecastItem {
    // Keeps the slot's time and precipitation chance, takes the observed temperature and sky.
    func replacingReading(with current: CurrentWeather) -> HourlyForecastItem {
        HourlyForecastItem(
            date: date,
            temperatureCelsius: current.temperatureCelsius,
            condition: current.condition,
            isDaytime: current.isDaytime,
            precipitationChancePercent: precipitationChancePercent
        )
    }
}
