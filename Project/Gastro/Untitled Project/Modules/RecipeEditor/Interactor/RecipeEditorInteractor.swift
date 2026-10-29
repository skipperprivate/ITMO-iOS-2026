import Combine
import Foundation

@MainActor
protocol RecipeEditorInteractor {
    func publish(_ draft: RecipeDraft) async throws -> PublishedRecipe

    func recipe(id: UUID) throws -> Recipe?

    func create(_ draft: RecipeDraft) throws

    func update(id: UUID, with draft: RecipeDraft) throws
}
