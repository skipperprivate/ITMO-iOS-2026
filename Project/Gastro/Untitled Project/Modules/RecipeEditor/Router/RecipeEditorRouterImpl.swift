@MainActor
final class RecipeEditorRouterImpl: RecipeEditorRouter {
    private let navigator: any AppNavigating

    init(navigator: any AppNavigating) {
        self.navigator = navigator
    }

    func goBack() {
        navigator.goBack()
    }
}
