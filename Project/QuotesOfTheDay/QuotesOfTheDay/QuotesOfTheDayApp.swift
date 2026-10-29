import SwiftUI
import SwiftData

@main
struct QuotesOfTheDayApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: SavedQuote.self)
    }
}
