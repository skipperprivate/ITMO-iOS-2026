import SwiftUI

@MainActor
final class RecipeDetailAssemblyImpl: RecipeDetailAssembly {
    func build(id: UUID, repository: any RecipeRepository, navigator: any AppNavigating) -> some View {
        RecipeDetailView(
            presenter: RecipeDetailPresenter(
                id: id,
                interactor: RecipeDetailInteractorImpl(repository: repository),
                router: RecipeDetailRouterImpl(navigator: navigator)
            )
        )
    }
}
