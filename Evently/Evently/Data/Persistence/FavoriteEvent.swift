import Foundation
import SwiftData

@Model
final class FavoriteEvent {

    @Attribute(.unique)
    var eventId: UUID

    var title: String
    var venue: String
    var city: String
    var date: Date
    var imageURL: URL?
    var price: String?
    var note: String
    var sourceID: String?
    var categoryRawValue: String?

    init(
        eventId: UUID,
        title: String,
        venue: String,
        city: String,
        date: Date,
        imageURL: URL?,
        price: String?,
        note: String = "",
        sourceID: String? = nil,
        categoryRawValue: String? = nil
    ) {
        self.eventId = eventId
        self.title = title
        self.venue = venue
        self.city = city
        self.date = date
        self.imageURL = imageURL
        self.price = price
        self.note = note
        self.sourceID = sourceID
        self.categoryRawValue = categoryRawValue
    }
}
