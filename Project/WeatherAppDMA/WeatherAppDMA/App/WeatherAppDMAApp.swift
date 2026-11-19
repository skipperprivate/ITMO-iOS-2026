import SwiftUI
import SwiftData

@main
struct WeatherAppDMAApp: App {
    var body: some Scene {
        WindowGroup {
            CompositionRoot.makeCitiesView()
                .environmentObject(CompositionRoot.preferencesStore)
                .modelContainer(CompositionRoot.modelContainer)
        }
    }
}
