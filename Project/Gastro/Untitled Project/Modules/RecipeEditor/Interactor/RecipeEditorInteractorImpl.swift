import Foundation

@MainActor
final class RecipeEditorInteractorImpl: RecipeEditorInteractor {
    private let repository: any RecipeRepository
    private let recipeService: any RecipeService

    init(repository: any RecipeRepository, recipeService: any RecipeService) {
        self.repository = repository
        self.recipeService = recipeService
    }

    func recipe(id: UUID) throws -> Recipe? {
        try repository.find(id: id)
    }

    func create(_ draft: RecipeDraft) throws {
        try repository.create(draft)
    }

    func update(id: UUID, with draft: RecipeDraft) throws {
        try repository.update(id: id, with: draft)
    }

    func publish(_ draft: RecipeDraft) async throws -> PublishedRecipe {
        try await recipeService.publishRecipe(draft.validated())
    }
}
