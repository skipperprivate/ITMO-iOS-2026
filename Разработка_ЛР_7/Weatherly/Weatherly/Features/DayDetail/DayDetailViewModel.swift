//
//  DayDetailViewModel.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// A slice of a forecast the previous screen already loaded; no network here.
@Observable
@MainActor
final class DayDetailViewModel {
    enum State {
        case loaded(day: DailyForecastItem, hours: [HourlyForecastItem])
        // The date isn't in the forecast (e.g. restored after the forecast window moved on).
        case unavailable
    }

    let city: City
    let date: Date
    let state: State

    init(snapshot: CityWeatherSnapshot, date: Date) {
        self.city = snapshot.city
        self.date = date
        if let day = snapshot.dailyItem(on: date) {
            state = .loaded(day: day, hours: snapshot.hourlyItems(on: day.date))
        } else {
            state = .unavailable
        }
    }

    var day: DailyForecastItem? {
        if case .loaded(let day, _) = state { return day }
        return nil
    }
}
