import Foundation

@MainActor
final class RecipeListInteractorImpl: RecipeListInteractor {
    private let repository: any RecipeRepository
    private let recipeService: any RecipeService

    init(repository: any RecipeRepository, recipeService: any RecipeService) {
        self.repository = repository
        self.recipeService = recipeService
    }

    func recipes() throws -> [Recipe] {
        try repository.fetchRecipes()
    }

    func remoteRecipes() async throws -> [RemoteRecipe] {
        try await recipeService.fetchRecipes()
    }

    func delete(id: UUID) throws {
        try repository.delete(id: id)
    }
}
