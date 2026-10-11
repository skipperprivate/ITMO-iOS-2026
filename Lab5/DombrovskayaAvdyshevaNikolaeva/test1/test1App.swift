import SwiftUI
import SwiftData

@main
struct RandomNumberApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: NumberEntry.self)
    }
}
