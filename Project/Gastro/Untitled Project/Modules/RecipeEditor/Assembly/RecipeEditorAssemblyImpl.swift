import SwiftUI

@MainActor
final class RecipeEditorAssemblyImpl: RecipeEditorAssembly {
    func build(
        id: UUID?,
        repository: any RecipeRepository,
        recipeService: any RecipeService,
        navigator: any AppNavigating
    ) -> some View {
        RecipeEditorView(
            presenter: RecipeEditorPresenter(
                id: id,
                interactor: RecipeEditorInteractorImpl(repository: repository, recipeService: recipeService),
                router: RecipeEditorRouterImpl(navigator: navigator)
            )
        )
    }
}
