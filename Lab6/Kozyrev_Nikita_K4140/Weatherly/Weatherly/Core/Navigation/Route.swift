//
//  Route.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// Push-only navigation, no sheets by design.
enum Route: Hashable {
    case places
    case cityPreview(City)
    // Carries the already loaded forecast: the day screen shows a slice of it, no second request.
    case dayDetail(snapshot: CityWeatherSnapshot, date: Date)
    case settings
}
