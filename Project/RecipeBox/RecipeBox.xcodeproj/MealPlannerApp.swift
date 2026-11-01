import SwiftUI
import SwiftData

@Model
class FavoriteMeal {
    @Attribute(.unique) var id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

@Model
class UserRecipe {
    @Attribute(.unique) var id: UUID
    var title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}

struct RootTabView: View {
    var body: some View {
        TabView {
            Text("Favorites View")
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
            Text("Recipes View")
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
        }
    }
}

@main
struct MealPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [FavoriteMeal.self, UserRecipe.self])
    }
}
