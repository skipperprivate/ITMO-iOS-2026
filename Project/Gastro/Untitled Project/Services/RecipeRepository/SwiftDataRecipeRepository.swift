import Foundation
import SwiftData

@MainActor
final class SwiftDataRecipeRepository: RecipeRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchRecipes() throws -> [Recipe] {
        try context.fetch(FetchDescriptor<Recipe>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]))
    }

    func find(id: UUID) throws -> Recipe? {
        let descriptor = FetchDescriptor<Recipe>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }

    @discardableResult
    func create(_ draft: RecipeDraft) throws -> UUID {
        let recipe = Recipe(draft: try draft.validated())
        context.insert(recipe)
        try context.save()
        return recipe.id
    }

    func update(id: UUID, with draft: RecipeDraft) throws {
        let validated = try draft.validated()
        guard let recipe = try find(id: id) else { throw RecipeStoreError.notFound }
        recipe.title = validated.title
        recipe.ingredients = validated.ingredients
        recipe.steps = validated.steps
        recipe.cookingTimeMinutes = validated.cookingTimeMinutes
        recipe.updatedAt = .now
        try context.save()
    }

    func delete(id: UUID) throws {
        guard let recipe = try find(id: id) else { throw RecipeStoreError.notFound }
        context.delete(recipe)
        try context.save()
    }
}
