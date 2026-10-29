import SwiftUI

@MainActor
final class RecipeListAssemblyImpl: RecipeListAssembly {
    func build(
        repository: any RecipeRepository,
        recipeService: any RecipeService,
        navigator: any AppNavigating
    ) -> some View {
        RecipeListView(
            presenter: RecipeListPresenter(
                interactor: RecipeListInteractorImpl(repository: repository, recipeService: recipeService),
                router: RecipeListRouterImpl(navigator: navigator)
            )
        )
    }
}
