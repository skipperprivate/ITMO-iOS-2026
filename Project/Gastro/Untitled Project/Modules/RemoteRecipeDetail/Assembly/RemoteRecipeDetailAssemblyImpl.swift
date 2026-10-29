import SwiftUI

@MainActor
final class RemoteRecipeDetailAssemblyImpl: RemoteRecipeDetailAssembly {
    func build(
        id: Int,
        recipeService: any RecipeService,
        navigator: any AppNavigating
    ) -> some View {
        RemoteRecipeDetailView(
            presenter: RemoteRecipeDetailPresenter(
                id: id,
                interactor: RemoteRecipeDetailInteractorImpl(recipeService: recipeService),
                router: RemoteRecipeDetailRouterImpl(navigator: navigator)
            )
        )
    }
}
