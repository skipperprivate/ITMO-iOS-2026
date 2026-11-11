//
//  RootView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

// The only place that touches AppContainer; screens get dependencies via ScreenFactory.
struct RootView: View {
    let container: AppContainer

    @State private var router: Router
    @State private var settingsStore: SettingsStore
    @State private var ambience: WeatherAmbience
    @State private var connectivity: ConnectivityMonitor
    @State private var homeViewModel: HomeViewModel

    @MainActor
    init(container: AppContainer) {
        self.container = container
        _router = State(initialValue: Router())
        _settingsStore = State(initialValue: SettingsStore(repository: container.settingsRepository))
        _ambience = State(initialValue: WeatherAmbience())
        _connectivity = State(initialValue: ConnectivityMonitor())
        _homeViewModel = State(initialValue: HomeViewModel(
            favoritesRepository: container.favoritesRepository,
            weatherRepository: container.weatherRepository,
            appStateRepository: container.appStateRepository
        ))
    }

    var body: some View {
        @Bindable var bindableRouter = router
        let factory = ScreenFactory(container: container, settingsStore: settingsStore) { city in
            homeViewModel.select(city)
            router.popToRoot()
        }

        NavigationStack(path: $bindableRouter.path) {
            HomeView(viewModel: homeViewModel)
                .navigationDestination(for: Route.self) { route in
                    factory.view(for: route)
                }
        }
        .environment(router)
        .environment(settingsStore)
        .environment(ambience)
        .environment(connectivity)
        .tint(WeatherPalette.ink)
        .preferredColorScheme(settingsStore.colorScheme(isDaytime: ambience.isDaytime))
    }
}

#if DEBUG
#Preview {
    RootView(container: PreviewSupport.container)
}
#endif
