import Foundation
import Observation

@MainActor
@Observable
final class FavoritesViewModel {

    private let repository: FavoritesRepository

    var favorites: [FavoriteEvent] = []
    var errorMessage: String?

    init(repository: FavoritesRepository) {
        self.repository = repository
    }

    func load() {
        do {
            favorites = try repository.fetchFavorites()
        } catch {
            errorMessage =
                "Не удалось загрузить избранное"
        }
    }

    func updateNote(
        eventId: UUID,
        note: String
    ) {
        do {
            try repository.updateNote(
                eventId: eventId,
                note: note
            )

            favorites =
                try repository.fetchFavorites()

        } catch {
            errorMessage =
                "Не удалось сохранить заметку"
        }
    }

    func delete(
        eventId: UUID
    ) {
        do {
            try repository.delete(
                eventId: eventId
            )

            favorites =
                try repository.fetchFavorites()

        } catch {
            errorMessage =
                "Не удалось удалить событие"
        }
    }
}
