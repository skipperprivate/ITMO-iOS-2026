import SwiftData
import SwiftUI

@main
struct MiniTwitterApp: App {
    @StateObject private var repositoryProvider: TweetRepositoryProvider
    private let usesTestStorage: Bool

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            usesTestStorage = true
            let suite = "MiniTwitter.UITests"
            UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite)
            _repositoryProvider = StateObject(wrappedValue:
                TweetRepositoryProvider(metadataSuite: suite, api: MockTweetsAPI()))
            return
        }
        #endif
        usesTestStorage = false
        _repositoryProvider = StateObject(wrappedValue: TweetRepositoryProvider())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(repositoryProvider)
        }
        .modelContainer(for: Tweet.self, inMemory: usesTestStorage)
    }
}
