import Foundation
import Observation

@MainActor
@Observable
final class EventDetailsViewModel {

    private(set) var event: Event
    private let favoritesRepository: FavoritesRepository
    private let eventRepository: EventRepository?

    var isFavorite = false
    var errorMessage: String?
    var detailsError: String?
    var isLoadingDetails = false

    init(
        event: Event,
        favoritesRepository: FavoritesRepository,
        eventRepository: EventRepository? = nil
    ) {
        self.event = event
        self.favoritesRepository = favoritesRepository
        self.eventRepository = eventRepository
    }

    func load() {
        do {
            isFavorite = try favoritesRepository.isFavorite(eventId: event.id)
        } catch {
            errorMessage = "Не удалось проверить избранное"
        }
    }

    func loadDetails() async {
        guard let id = event.sourceID, let eventRepository, !isLoadingDetails else { return }
        isLoadingDetails = true
        detailsError = nil
        defer { isLoadingDetails = false }

        do {
            let details = try await eventRepository.fetchEventDetails(id: id)
            try Task.checkCancellation()
            if let details, details.id == event.id {
                event = details
            }
        } catch is CancellationError {
            return
        } catch {
            detailsError = error.localizedDescription
        }
    }

    func toggleFavorite() {
        do {
            if isFavorite {
                try favoritesRepository.delete(eventId: event.id)
            } else {
                try favoritesRepository.add(event)
            }
            isFavorite.toggle()
            errorMessage = nil
        } catch {
            errorMessage = "Не удалось изменить избранное"
        }
    }
}
