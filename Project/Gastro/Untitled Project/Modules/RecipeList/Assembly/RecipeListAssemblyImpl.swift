import SwiftUI

@MainActor
final class RecipeListAssemblyImpl: RecipeListAssembly {
    func build(
        repository: any RecipeRepository,
        recipeService: any RecipeService,
        favoriteStore: any FavoriteRecipeStore,
        navigator: any AppNavigating
    ) -> some View {
        RecipeListView(
            presenter: RecipeListPresenter(
                interactor: RecipeListInteractorImpl(
                    repository: repository,
                    recipeService: recipeService,
                    favoriteStore: favoriteStore
                ),
                router: RecipeListRouterImpl(navigator: navigator)
            )
        )
    }
}
