@MainActor
final class ProfileRouterImpl: ProfileRouter {
    private let navigator: any AppNavigating

    init(navigator: any AppNavigating) {
        self.navigator = navigator
    }

    func showNetworkExamples() {
        navigator.showNetworkExamples()
    }

    func showRecipes() {
        navigator.showRecipes()
    }
}
