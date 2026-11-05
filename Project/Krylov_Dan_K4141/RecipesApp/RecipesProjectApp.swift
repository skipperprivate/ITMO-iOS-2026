import SwiftData
import SwiftUI

@main
struct RecipesProjectApp: App {
    let container: ModelContainer

    init() {
        let isUITesting = CommandLine.arguments.contains("-uiTesting")
        if isUITesting, let id = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: id)
        }
        let config = ModelConfiguration(isStoredInMemoryOnly: isUITesting)
        do {
            container = try ModelContainer(for: Recipe.self, configurations: config)
        } catch {
            fatalError("Не удалось открыть базу рецептов: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RecipeListView()
                .tint(.orange)
        }
        .modelContainer(container)
    }
}
