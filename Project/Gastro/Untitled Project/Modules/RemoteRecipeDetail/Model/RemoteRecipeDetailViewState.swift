import Foundation

struct RemoteRecipeDetailViewState: Equatable {
    var title = "Recipe"
    var ingredients: [String] = []
    var steps: [String] = []
    var imageURL: URL?
    var cookingTimeMinutes: Int?
    var isLoaded = false
    var isLoading = false
    var error: String?
}
