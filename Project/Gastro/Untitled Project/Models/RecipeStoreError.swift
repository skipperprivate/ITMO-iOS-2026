import Foundation

nonisolated enum RecipeStoreError: LocalizedError {
    case emptyTitle
    case emptyIngredients
    case emptySteps
    case invalidCookingTime
    case notFound

    var errorDescription: String? {
        switch self {
            case .emptyTitle: "Enter a recipe name"
            case .emptyIngredients: "Add at least one ingredient"
            case .emptySteps: "Add at least one step"
            case .invalidCookingTime: "Cooking time must be a positive number of minutes"
            case .notFound: "Recipe not found"
        }
    }
}
