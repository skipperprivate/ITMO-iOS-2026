import Foundation

extension FavoriteEvent {
    var asEvent: Event {
        Event(
            id: eventId,
            title: title,
            category: EventCategoryRu(rawValue: categoryRawValue ?? "") ?? .other,
            venue: venue,
            city: city,
            date: date,
            imageURL: imageURL,
            price: price,
            sourceID: sourceID
        )
    }
}
