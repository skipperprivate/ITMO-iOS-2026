import Foundation

@MainActor
protocol RecipeRepository {
    func fetchRecipes() throws -> [Recipe]

    func find(id: UUID) throws -> Recipe?
    @discardableResult func create(_ draft: RecipeDraft) throws -> UUID
    func update(id: UUID, with draft: RecipeDraft) throws

    func delete(id: UUID) throws
}
