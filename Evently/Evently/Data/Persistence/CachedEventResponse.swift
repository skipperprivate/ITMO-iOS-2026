import Foundation
import SwiftData

@Model
final class CachedEventResponse {
    @Attribute(.unique) var key: String
    var payload: Data
    var updatedAt: Date

    init(key: String, payload: Data, updatedAt: Date = .now) {
        self.key = key
        self.payload = payload
        self.updatedAt = updatedAt
    }
}

struct CachedEventSnapshot: Codable {
    let id: UUID
    let title: String
    let category: String
    let venue: String
    let city: String
    let date: Date
    let imageURL: URL?
    let price: String?
    let isFeatured: Bool
    let sourceID: String?
    let description: String?
    let address: String?
    let ticketURL: URL?

    init(_ event: Event) {
        id = event.id
        title = event.title
        category = event.category.rawValue
        venue = event.venue
        city = event.city
        date = event.date
        imageURL = event.imageURL
        price = event.price
        isFeatured = event.isFeatured
        sourceID = event.sourceID
        description = event.description
        address = event.address
        ticketURL = event.ticketURL
    }

    var event: Event {
        Event(
            id: id,
            title: title,
            category: EventCategoryRu(rawValue: category) ?? .other,
            venue: venue,
            city: city,
            date: date,
            imageURL: imageURL,
            price: price,
            isFeatured: isFeatured,
            sourceID: sourceID,
            description: description,
            address: address,
            ticketURL: ticketURL
        )
    }
}

struct CachedPageSnapshot: Codable {
    let events: [CachedEventSnapshot]
    let page: Int
    let hasMore: Bool

    @MainActor init(_ page: EventPage) {
        events = page.events.map(CachedEventSnapshot.init)
        self.page = page.page
        hasMore = page.hasMore
    }

    var eventPage: EventPage {
        EventPage(events: events.map(\.event), page: page, hasMore: hasMore)
    }
}
