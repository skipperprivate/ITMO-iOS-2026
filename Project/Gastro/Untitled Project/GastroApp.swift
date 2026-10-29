import SwiftData
import SwiftUI

@main
struct GastroApp: App {
    private var usesInMemoryStore: Bool {
        #if DEBUG
        UITestingConfiguration.isEnabled
        #else
        false
        #endif
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(for: Recipe.self, inMemory: usesInMemoryStore)
        }
    }
}
