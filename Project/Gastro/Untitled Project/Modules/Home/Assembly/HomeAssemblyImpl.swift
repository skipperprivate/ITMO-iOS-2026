import SwiftUI

@MainActor
final class HomeAssemblyImpl: HomeAssembly {
    func build(repository: any RecipeRepository, navigator: any AppNavigating) -> some View {
        HomeView(
            presenter: HomePresenter(
                interactor: HomeInteractorImpl(repository: repository),
                router: HomeRouterImpl(navigator: navigator)
            )
        )
    }
}
