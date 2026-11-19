//
//  WeatherAmbience.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// Weather of the city shown on Home; drives backgrounds and the auto theme app-wide.
@Observable
@MainActor
final class WeatherAmbience {
    private(set) var condition: WeatherCondition?
    private(set) var isDaytime: Bool

    init(now: Date = Date(), calendar: Calendar = .current) {
        // Guess from the device clock until data arrives to avoid a light-to-dark flash.
        isDaytime = (7..<20).contains(calendar.component(.hour, from: now))
    }

    func update(with current: CurrentWeather?) {
        guard let current else { return }
        condition = current.condition
        isDaytime = current.isDaytime
    }
}
