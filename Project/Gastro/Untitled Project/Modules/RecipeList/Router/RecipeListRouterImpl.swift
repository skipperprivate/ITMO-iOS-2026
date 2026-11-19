import Foundation

@MainActor
final class RecipeListRouterImpl: RecipeListRouter {
    private let navigator: any AppNavigating

    init(navigator: any AppNavigating) {
        self.navigator = navigator
    }

    func showRecipe(id: UUID) {
        navigator.showRecipe(id: id)
    }

    func showRemoteRecipe(id: Int) {
        navigator.showRemoteRecipe(id: id)
    }

    func showNewRecipe() {
        navigator.showNewRecipe()
    }
}
