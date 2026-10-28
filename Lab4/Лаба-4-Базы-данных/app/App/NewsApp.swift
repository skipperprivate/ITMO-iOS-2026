import SwiftUI
import SwiftData

@main
struct NewsApp: App {
    private let container: ModelContainer
    private let repository: NewsRepository
    @State private var settings = SettingsViewModel()

    init() {
        do {
            let container = try PersistenceController.makeContainer()
            self.container = container
            repository = NewsRepository(context: container.mainContext)
        } catch {
            fatalError("Не удалось открыть хранилище: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            NewsFeedView(repository: repository)
                .environment(settings)
        }
        .modelContainer(container)
    }
}
