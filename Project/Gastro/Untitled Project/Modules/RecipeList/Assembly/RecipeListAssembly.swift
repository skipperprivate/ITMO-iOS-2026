import SwiftUI

@MainActor
protocol RecipeListAssembly {
    associatedtype Content: View

    func build(
        repository: any RecipeRepository,
        recipeService: any RecipeService,
        favoriteStore: any FavoriteRecipeStore,
        navigator: any AppNavigating
    ) -> Content
}
