protocol RecipeService: Sendable {
    func fetchRecipes() async throws -> [RemoteRecipe]

    func fetchRecipe(id: Int) async throws -> RemoteRecipe

    func publishRecipe(_ draft: RecipeDraft) async throws -> PublishedRecipe
}
