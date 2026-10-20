import SwiftUI
import SwiftData

@main
struct RecipesProjectApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView()
                .tint(.orange)
        }
        .modelContainer(for: Recipe.self)
    }
}
