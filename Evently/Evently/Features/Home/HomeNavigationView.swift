import SwiftUI

struct HomeNavigationView: View {

    let container: AppContainer

    var body: some View {
        NavigationStack {
            HomeView(
                viewModel: container.makeHomeViewModel()
            )
            .id(container.locationStore.selectionKey)
            .navigationDestination(
                for: AppRoute.self
            ) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(
        for route: AppRoute
    ) -> some View {
        switch route {
        case .search:
            SearchView(
                viewModel: container.makeSearchViewModel(),
                locationStore: container.locationStore
            )

        case .eventDetails(let event):
            EventDetailsView(
                viewModel:
                    container.makeEventDetailsViewModel(
                        event: event
                    )
            )

        default:
            SettingsView(
                viewModel: container.makeFeedbackViewModel(),
                locationStore: container.locationStore,
                appInfo: container.appInfoProvider.getInfo(),
                reminderCoordinator: container.reminderCoordinator
            )
        }
    }
}
