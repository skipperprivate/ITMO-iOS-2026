import Foundation

@MainActor
final class ReminderAwareFavoritesRepository: FavoritesRepository {
    private let wrapped: any FavoritesRepository
    private let reminders: ReminderCoordinator

    init(wrapped: any FavoritesRepository, reminders: ReminderCoordinator) {
        self.wrapped = wrapped
        self.reminders = reminders
    }

    func fetchFavorites() throws -> [FavoriteEvent] {
        try wrapped.fetchFavorites()
    }

    func isFavorite(eventId: UUID) throws -> Bool {
        try wrapped.isFavorite(eventId: eventId)
    }

    func add(_ event: Event) throws {
        try wrapped.add(event)
        reminders.synchronize(requestAuthorization: true)
    }

    func delete(eventId: UUID) throws {
        try wrapped.delete(eventId: eventId)
        reminders.synchronize()
    }

    func updateNote(eventId: UUID, note: String) throws {
        try wrapped.updateNote(eventId: eventId, note: note)
    }
}
