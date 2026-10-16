import Foundation

nonisolated enum ForecastFreshness {
    static let freshInterval: TimeInterval = 15 * 60
    static let maximumDisplayAge: TimeInterval = 72 * 3600

    static func isFresh(_ fetchedAt: Date, now: Date) -> Bool {
        let age = now.timeIntervalSince(fetchedAt)
        return age >= 0 && age < freshInterval
    }

    static func isDisplayable(_ fetchedAt: Date, now: Date) -> Bool {
        now.timeIntervalSince(fetchedAt) < maximumDisplayAge
    }
}

nonisolated enum CachePolicy: Sendable {
    case returnFreshCache
    case reloadIgnoringCache
}
