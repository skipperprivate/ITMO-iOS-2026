@MainActor
final class HomeRouterImpl: HomeRouter {
    private let navigator: any AppNavigating

    init(navigator: any AppNavigating) {
        self.navigator = navigator
    }

    func showRecipes() {
        navigator.showRecipes()
    }

    func showProfile() {
        navigator.showProfile()
    }
}
