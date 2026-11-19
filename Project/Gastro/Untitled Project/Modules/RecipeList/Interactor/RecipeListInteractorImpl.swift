import Foundation

@MainActor
final class RecipeListInteractorImpl: RecipeListInteractor {
    private let favoriteStore: any FavoriteRecipeStore
    private let repository: any RecipeRepository
    private let recipeService: any RecipeService

    init(repository: any RecipeRepository, recipeService: any RecipeService, favoriteStore: any FavoriteRecipeStore) {
        self.favoriteStore = favoriteStore
        self.repository = repository
        self.recipeService = recipeService
    }

    func favorites() throws -> [RecipeRowState] {
        try favoriteStore.load()
    }

    func saveFavorites(_ recipes: [RecipeRowState]) throws {
        try favoriteStore.save(recipes)
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
