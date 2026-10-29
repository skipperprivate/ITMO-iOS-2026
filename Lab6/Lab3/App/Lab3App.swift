import SwiftData
import SwiftUI

@main
struct Lab3App: App {
    @StateObject private var repositoryProvider = TweetRepositoryProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(repositoryProvider)
        }
        .modelContainer(for: Tweet.self)
    }
}
