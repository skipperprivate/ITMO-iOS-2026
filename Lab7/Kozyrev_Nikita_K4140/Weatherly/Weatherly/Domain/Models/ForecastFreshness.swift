//
//  ForecastFreshness.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation

nonisolated enum ForecastFreshness {
    // Open-Meteo updates current conditions every 15 minutes; a newer request would bring the same data.
    static let freshInterval: TimeInterval = 15 * 60
    // Older data isn't shown even offline: "now" would be days off and the forecast mostly past.
    static let maximumDisplayAge: TimeInterval = 72 * 3600

    // A timestamp from the future (the clock was moved back) counts as stale, never as fresh.
    static func isFresh(_ fetchedAt: Date, now: Date) -> Bool {
        let age = now.timeIntervalSince(fetchedAt)
        return age >= 0 && age < freshInterval
    }

    static func isDisplayable(_ fetchedAt: Date, now: Date) -> Bool {
        now.timeIntervalSince(fetchedAt) < maximumDisplayAge
    }
}

nonisolated enum CachePolicy: Sendable {
    // Data younger than ForecastFreshness.freshInterval is answered without a request.
    case returnFreshCache
    // Pull-to-refresh: always ask the server.
    case reloadIgnoringCache
}
