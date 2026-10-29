import Foundation

enum RecipeRowID: Hashable {
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

struct RecipeRowState: Identifiable, Equatable {
    let id: RecipeRowID
    let title: String
    let ingredientCount: Int
    let cookingTimeMinutes: Int?
}

struct RecipeListViewState: Equatable {
    var recipes: [RecipeRowState] = []
    var isLoadingRemote = false
    var remoteError: String?
    var error: String?
}
