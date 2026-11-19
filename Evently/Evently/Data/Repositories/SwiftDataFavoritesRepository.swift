import Foundation
import SwiftData

final class SwiftDataFavoritesRepository: FavoritesRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchFavorites() throws -> [FavoriteEvent] {
        let descriptor = FetchDescriptor<FavoriteEvent>(
                sortBy: [
                    SortDescriptor(\.date)
                ]
            )

        return try context.fetch(
            descriptor
        )
    }

    func isFavorite(eventId: UUID) throws -> Bool {
        let descriptor = FetchDescriptor<FavoriteEvent>(
                predicate: #Predicate {
                    $0.eventId == eventId
                }
            )

        return try !context
            .fetch(descriptor)
            .isEmpty
    }

    func add(_ event: Event) throws {
        let favorite = FavoriteEvent(
            eventId: event.id,
            title: event.title,
            venue: event.venue,
            city: event.city,
            date: event.date,
            imageURL: event.imageURL,
            price: event.price,
            sourceID: event.sourceID,
            categoryRawValue: event.category.rawValue
        )

        context.insert(favorite)

        try context.save()
    }

    func delete(eventId: UUID) throws {
        let descriptor = FetchDescriptor<FavoriteEvent>(
                predicate: #Predicate {
                    $0.eventId == eventId
                }
            )

        guard let favorite = try context
                .fetch(descriptor)
                .first
        else {
            return
        }

        context.delete(favorite)

        try context.save()
    }

    func updateNote(eventId: UUID, note: String) throws {
        let descriptor = FetchDescriptor<FavoriteEvent>(
                predicate: #Predicate {
                    $0.eventId == eventId
                }
            )

        guard let favorite = try context
                .fetch(descriptor)
                .first
        else {
            return
        }

        favorite.note = note
        try context.save()
    }
}
