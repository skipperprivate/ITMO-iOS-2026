import SwiftUI
import SwiftData

@main
@MainActor
struct SomeWeatherApp: App {
    private let container: ModelContainer?
    @StateObject private var weather: WeatherViewModel

    init() {
        let isUITesting = CommandLine.arguments.contains("-uiTesting")
        let settings: SettingsStore
        if isUITesting, let defaults = UserDefaults(suiteName: "SomeWeatherUITests") {
            defaults.removePersistentDomain(forName: "SomeWeatherUITests")
            settings = SettingsStore(defaults: defaults)
        } else {
            settings = SettingsStore()
        }
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: isUITesting)
            let container = try ModelContainer(for: SavedCity.self, configurations: configuration)
            self.container = container
            let repository = CityRepository(context: container.mainContext)
            _weather = StateObject(wrappedValue: WeatherViewModel(
                repository: repository, settings: settings
            ))
        } catch {
            container = nil
            _weather = StateObject(wrappedValue: WeatherViewModel(
                repository: nil, settings: settings,
                storageError: "Не удалось открыть хранилище городов. Перезапустите приложение."
            ))
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(weather)
        }
    }
}
