import Foundation

struct RecipeDetailViewState: Equatable {
    var title = ""
    var ingredients: [String] = []
    var steps: [String] = []
    var cookingTimeMinutes: Int?
    var isLoaded = false
    var error: String?
}
