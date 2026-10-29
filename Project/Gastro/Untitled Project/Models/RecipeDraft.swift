import Foundation

nonisolated struct RecipeDraft: Equatable, Sendable {
    var title: String
    var ingredients: [String]
    var steps: [String]
    var cookingTimeMinutes: Int?

    static let empty = RecipeDraft(
        title: "",
        ingredients: [""],
        steps: [""],
        cookingTimeMinutes: nil
    )

    func validated() throws -> RecipeDraft {
        let result = RecipeDraft(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty },
            steps: steps.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty },
            cookingTimeMinutes: cookingTimeMinutes
        )
        guard !result.title.isEmpty else { throw RecipeStoreError.emptyTitle }
        guard !result.ingredients.isEmpty else { throw RecipeStoreError.emptyIngredients }
        guard !result.steps.isEmpty else { throw RecipeStoreError.emptySteps }
        if let minutes = result.cookingTimeMinutes, minutes <= 0 {
            throw RecipeStoreError.invalidCookingTime
        }
        return result
    }
}
