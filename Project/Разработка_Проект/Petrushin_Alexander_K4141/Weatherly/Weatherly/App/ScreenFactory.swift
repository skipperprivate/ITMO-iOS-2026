//
//  ScreenFactory.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

// Screens keep the received ViewModel in @State, so re-created instances are discarded.
struct ScreenFactory {
    let container: AppContainer
    let settingsStore: SettingsStore
    let onSelectFavorite: (City) -> Void

    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .places:
            PlacesView(
                placesViewModel: PlacesViewModel(
                    favoritesRepository: container.favoritesRepository,
                    weatherRepository: container.weatherRepository
                ),
                searchViewModel: SearchViewModel(geocodingRepository: container.geocodingRepository),
                onSelectFavorite: onSelectFavorite
            )
        case .cityPreview(let city):
            CityPreviewView(viewModel: CityPreviewViewModel(
                city: city,
                weatherRepository: container.weatherRepository,
                favoritesRepository: container.favoritesRepository
            ))
        case .dayDetail(let snapshot, let date):
            DayDetailView(viewModel: DayDetailViewModel(snapshot: snapshot, date: date))
        case .settings:
            SettingsView(viewModel: SettingsViewModel(store: settingsStore))
        }
    }
}
