import SwiftUI
import SwiftData

@main
@MainActor
struct NewsApp: App {
    private let api: NewsAPIClient
    private let container: ModelContainer?
    private let repository: NewsRepository?
    private let startupError: String?
    @State private var settings = SettingsViewModel()

    init() {
        var isUITesting = false
#if DEBUG
        isUITesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
        api = isUITesting
            ? NewsAPIClient(transport: UITestTransport(failFirstRequest: ProcessInfo.processInfo.arguments.contains("--fail-first-request")))
            : NewsAPIClient()
#else
        api = NewsAPIClient()
#endif
        do {
            let storage = try isUITesting
                ? ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
                : PersistenceController().makeContainer()
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
