nonisolated struct RecipesResponse: Decodable, Sendable {
    let recipes: [RecipeResponse]
}
