import SwiftUI

struct MainTabView: View {

    let container: AppContainer

    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {

            Tab(
                "Главная",
                systemImage: "house.fill",
                value: .home
            ) {
                HomeNavigationView(
                    container: container
                )
            }

            Tab(
                "Избранное",
                systemImage: "heart.fill",
                value: .favorites
            ) {
                FavoritesNavigationView(
                    container: container
                )
            }

            Tab(
                "Настройки",
                systemImage: "gearshape.fill",
                value: .settings
            ) {
                NavigationStack {
                    SettingsView(
                        viewModel: container.makeFeedbackViewModel(),
                        locationStore: container.locationStore,
                        appInfo: container.makeAppInfo(),
                        reminderCoordinator: container.reminderCoordinator
                    )
                }
            }
        }
        .tint(.purple)
    }
}

extension MainTabView {
    enum AppTab: Hashable {
        case home
        case favorites
        case settings
    }
}
