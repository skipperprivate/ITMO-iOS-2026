import Foundation

@MainActor
final class AppContainer {
    let eventRepository: EventRepository
    let favoritesRepository: FavoritesRepository
    let feedbackRepository: FeedbackRepository
    let locationStore: LocationStore
    let appInfoProvider: any AppInfoProviding
    let reminderCoordinator: ReminderCoordinator

    init(
        eventRepository: EventRepository,
        favoritesRepository: FavoritesRepository,
        feedbackRepository: FeedbackRepository,
        locationStore: LocationStore,
        appInfoProvider: AppInfoProviding,
        reminderCoordinator: ReminderCoordinator
    ) {
        self.eventRepository = eventRepository
        self.favoritesRepository = favoritesRepository
        self.feedbackRepository = feedbackRepository
        self.locationStore = locationStore
        self.appInfoProvider = appInfoProvider
        self.reminderCoordinator = reminderCoordinator
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            repository: eventRepository
        )
    }

    func makeAppInfo() -> AppInfo {
        appInfoProvider.getInfo()
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            repository: favoritesRepository
        )
    }
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(repository: eventRepository)
    }

    func makeEventDetailsViewModel(
        event: Event
    ) -> EventDetailsViewModel {
        EventDetailsViewModel(
            event: event,
            favoritesRepository: favoritesRepository,
            eventRepository: eventRepository
        )
    }

    func makeFeedbackViewModel() -> FeedbackViewModel {
        FeedbackViewModel(
            repository: feedbackRepository
        )
    }
}
