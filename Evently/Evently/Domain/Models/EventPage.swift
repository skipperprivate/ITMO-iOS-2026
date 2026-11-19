import Foundation

struct EventPage: Sendable {
    let events: [Event]
    let page: Int
    let hasMore: Bool
}
