import Foundation

@MainActor
final class RecipeDetailRouterImpl: RecipeDetailRouter {
    private let navigator: any AppNavigating

    init(navigator: any AppNavigating) {
        self.navigator = navigator
    }

    func editRecipe(id: UUID) {
        navigator.editRecipe(id: id)
    }

    func goBack() {
        navigator.goBack()
    }
}
