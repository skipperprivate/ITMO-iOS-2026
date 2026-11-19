import Foundation

protocol FavoritesRepository {
    func fetchFavorites() throws -> [FavoriteEvent]

    func isFavorite(eventId: UUID) throws -> Bool

    func add(_ event: Event) throws

    func delete(eventId: UUID) throws

    func updateNote(
        eventId: UUID,
        note: String
    ) throws
}
