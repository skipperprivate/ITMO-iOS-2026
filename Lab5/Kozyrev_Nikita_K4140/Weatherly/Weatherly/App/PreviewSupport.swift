//
//  PreviewSupport.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

#if DEBUG
import SwiftUI

@MainActor
enum PreviewSupport {
    static let container: AppContainer = {
        AppFont.register()
        let defaults = UserDefaults(suiteName: "weatherly.previews") ?? .standard
        return AppContainer(
            weatherRepository: MockWeatherRepository(),
            geocodingRepository: MockGeocodingRepository(),
            favoritesRepository: InMemoryFavoritesRepository(initialCities: Array(MockData.allCities.prefix(3))),
            settingsRepository: UserDefaultsSettingsRepository(defaults: defaults),
            appStateRepository: UserDefaultsAppStateRepository(defaults: defaults)
        )
    }()

    static let settingsStore = SettingsStore(repository: container.settingsRepository)
    static let connectivity = ConnectivityMonitor()
    static let city = MockData.allCities[0]
    static let snapshot = MockData.snapshot(for: city)
}

extension View {
    func previewEnvironment(isDaytime: Bool = false) -> some View {
        let ambience = WeatherAmbience()
        ambience.update(with: PreviewSupport.snapshot.current)
        return NavigationStack { self }
            .environment(Router())
            .environment(PreviewSupport.settingsStore)
            .environment(ambience)
            .environment(PreviewSupport.connectivity)
            .tint(WeatherPalette.ink)
            .preferredColorScheme(isDaytime ? .light : .dark)
    }

    // Standalone component on the weather backdrop; touching `container` registers the fonts.
    func previewOnBackdrop(isDaytime: Bool = false, padding: CGFloat = 16) -> some View {
        _ = PreviewSupport.container
        return ZStack {
            WeatherBackgroundView(condition: PreviewSupport.snapshot.current.condition, isDaytime: isDaytime)
            self.padding(padding)
        }
        .weatherScreenStyle()
        .previewEnvironment(isDaytime: isDaytime)
    }
}
#endif
