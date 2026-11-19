import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class RecipeDetailViewModel {
    private(set) var recipe: Recipe
    var servings: Int
    var errorMessage: String?

    init(recipe: Recipe) {
        self.recipe = recipe
        servings = recipe.baseServings
    }

    func refresh(in context: ModelContext) {
        let id = recipe.id
        let descriptor = FetchDescriptor<Recipe>(predicate: #Predicate { $0.id == id })
        do {
            if let updated = try context.fetch(descriptor).first {
                recipe = updated
                servings = updated.baseServings
            }
        } catch {
            errorMessage = "Не удалось обновить рецепт. Попробуй ещё раз."
        }
    }

    func quantity(for ingredient: RecipeIngredient, recipe: Recipe) -> String {
        let multiplier = Double(servings) / Double(recipe.baseServings)
        return RecipeFormatting.quantity(ingredient.quantity * multiplier, unit: ingredient.unit)
    }

    func toggleFavorite(_ recipe: Recipe, in context: ModelContext) {
        recipe.isFavorite.toggle()
        
        do {
            try context.save()
        } catch {
            context.rollback()
            errorMessage = "Не удалось обновить избранное. Попробуй ещё раз."
        }
    }

    func delete(_ recipe: Recipe, in context: ModelContext) -> Bool {
        do {
            let recipeID = recipe.id
            let entries = try context.fetch(FetchDescriptor<MealPlanEntry>(
                predicate: #Predicate { $0.recipe.id == recipeID }
            ))
            entries.forEach { context.delete($0) }
            context.delete(recipe)
            try context.save()
            return true
        } catch {
            context.rollback()
            errorMessage = "Не удалось удалить рецепт. Попробуй ещё раз."
            return false
        }
    }
}
