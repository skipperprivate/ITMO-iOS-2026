import SwiftUI

@MainActor
final class NetworkExamplesAssemblyImpl: NetworkExamplesAssembly {
    func build(service: any NetworkExamplesService, navigator: any AppNavigating) -> some View {
        NetworkExamplesView(
            presenter: NetworkExamplesPresenter(
                interactor: NetworkExamplesInteractorImpl(service: service),
                router: NetworkExamplesRouterImpl(navigator: navigator)
            )
        )
    }
}
