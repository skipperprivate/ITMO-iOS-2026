import Foundation

nonisolated enum EventCatalogConfiguration {
    static let defaultCountryCode = "US"
    static let pageSize = 40
    static let featuredEventsCount = 5
    static let searchDebounce: Duration = .milliseconds(350)
    static let ticketmasterResultWindow = 1_000
}
