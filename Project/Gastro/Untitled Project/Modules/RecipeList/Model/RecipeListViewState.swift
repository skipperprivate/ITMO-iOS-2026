import Foundation

enum RecipeRowID: Hashable, Codable {
    case local(UUID)
    case remote(Int)

    var sourceSymbol: String {
        switch self {
            case .local: "person.fill"
            case .remote: "globe"
        }
    }

    var sourceAccessibilityLabel: String {
        switch self {
            case .local: "Saved on this device"
            case .remote: "Online recipe"
        }
    }
}

struct RecipeRowState: Identifiable, Equatable, Codable {
    let id: RecipeRowID
    let title: String
    let ingredientCount: Int
    let cookingTimeMinutes: Int?
    var image: URL?
    var ingredientSummary: String = ""
}

struct RecipeListViewState: Equatable {
    var recipes: [RecipeRowState] = []
    var favorites: [RecipeRowState] = []
    var skippedIDs: Set<RecipeRowID> = []

    var recommendations: [RecipeRowState] {
        recipes.filter { row in
            !skippedIDs.contains(row.id) && !favorites.contains { $0.id == row.id }
        }
    }

    var isLoadingRemote = false
    var remoteError: String?
    var error: String?
}
