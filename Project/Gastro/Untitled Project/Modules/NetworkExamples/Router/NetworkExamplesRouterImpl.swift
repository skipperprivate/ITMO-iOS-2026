@MainActor
final class NetworkExamplesRouterImpl: NetworkExamplesRouter {
    private let navigator: any AppNavigating

    init(navigator: any AppNavigating) {
        self.navigator = navigator
    }

    func goBack() {
        navigator.goBack()
    }
}
