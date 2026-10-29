@MainActor
final class RemoteRecipeDetailInteractorImpl: RemoteRecipeDetailInteractor {
    private let recipeService: any RecipeService

    init(recipeService: any RecipeService) {
        self.recipeService = recipeService
    }

    func recipe(id: Int) async throws -> RemoteRecipe {
        try await recipeService.fetchRecipe(id: id)
    }
}
