import SwiftData
import SwiftUI

@main
struct EventlyApp: App {
    private let modelContainer: ModelContainer
    private let container: AppContainer

    init() {
        do {
            let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")
            let configuration = ModelConfiguration(isStoredInMemoryOnly: isUITesting)


            let modelContainer = try ModelContainer(
                for: FavoriteEvent.self, CachedEventResponse.self,
                configurations: configuration
            )
            self.modelContainer = modelContainer

            let locationStore = LocationStore()
            let eventRepository = Self.makeEventRepository(
                isUITesting: isUITesting,
                modelContainer: modelContainer,
                locationStore: locationStore
            )

            let feedbackRepository = RemoteFeedbackRepository(
                apiClient: FeedbackAPIClient()
            )

            let baseFavorites = SwiftDataFavoritesRepository(context: modelContainer.mainContext)
            let reminderCoordinator = ReminderCoordinator(
                favorites: baseFavorites,
                scheduler: UNLocalNotificationScheduler()
            )
            let favoriteRepository = ReminderAwareFavoritesRepository(
                wrapped: baseFavorites,
                reminders: reminderCoordinator
            )

            self.container = AppContainer(
                eventRepository: eventRepository,
                favoritesRepository: favoriteRepository,
                feedbackRepository: feedbackRepository,
                locationStore: locationStore,
                appInfoProvider: BundleAppInfoProvider(),
                reminderCoordinator: reminderCoordinator
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    private static func makeEventRepository(
        isUITesting: Bool,
        modelContainer: ModelContainer,
        locationStore: LocationStore
    ) -> any EventRepository {
        if isUITesting {
            return MockEventRepository()
        }

        guard let apiKey = Bundle.main.object(
            forInfoDictionaryKey: "TicketmasterAPIKey"
        ) as? String,
            !apiKey.isEmpty,
            !apiKey.contains("$(") else {
            fatalError("Ticketmaster API key is missing")
        }

        let remote = TicketmasterEventRepository(
            apiClient: TicketmasterAPIClient(apiKey: apiKey),
            locationStore: locationStore
        )

        return CachedEventRepository(
            remote: remote,
            context: modelContainer.mainContext,
            locationStore: locationStore
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .task {
                    container.reminderCoordinator.synchronize()
                }
        }
        .modelContainer(modelContainer)
    }
}
