import SwiftUI
import SwiftData

@main
@MainActor
struct SomeWeatherApp: App {
    private let container: ModelContainer?
    @StateObject private var weather: WeatherViewModel

    init() {
        let settings = SettingsStore()
        do {
            let container = try ModelContainer(for: SavedCity.self)
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
