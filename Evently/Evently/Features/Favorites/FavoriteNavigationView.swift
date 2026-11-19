import SwiftUI

struct FavoritesNavigationView: View {
    let container: AppContainer

    var body: some View {
        NavigationStack {
            FavoritesView(viewModel: container.makeFavoritesViewModel())
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .eventDetails(let event):
                        EventDetailsView(
                            viewModel: container.makeEventDetailsViewModel(event: event)
                        )
                    case .search:
                        SearchView(
                            viewModel: container.makeSearchViewModel(),
                            locationStore: container.locationStore
                        )
                    case .settings:
                        SettingsView(
                            viewModel: container.makeFeedbackViewModel(),
                            locationStore: container.locationStore,
                            appInfo: container.appInfoProvider.getInfo(),
                            reminderCoordinator: container.reminderCoordinator
                        )
                    }
                }
        }
    }
}
