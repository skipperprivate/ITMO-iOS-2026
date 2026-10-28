import SwiftUI
import SwiftData

@main
@MainActor
struct NewsApp: App {
    private let api = NewsAPIClient()
    private let container: ModelContainer?
    private let repository: NewsRepository?
    private let startupError: String?
    @State private var settings = SettingsViewModel()

    init() {
        do {
            let storage = try PersistenceController().makeContainer()
            container = storage
            repository = NewsRepository(context: storage.mainContext)
            startupError = nil
        } catch {
            container = nil
            repository = nil
            startupError = error.localizedDescription
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container, let repository {
                NewsFeedView(repository: repository, newsService: api, publisher: api)
                    .environment(settings)
                    .modelContainer(container)
            } else {
                ContentUnavailableView("Не удалось открыть хранилище", systemImage: "externaldrive.badge.exclamationmark",
                                       description: Text(startupError ?? "Перезапустите приложение."))
            }
        }
    }
}
