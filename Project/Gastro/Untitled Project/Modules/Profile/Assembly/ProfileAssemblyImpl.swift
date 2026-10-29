import SwiftUI

@MainActor
final class ProfileAssemblyImpl: ProfileAssembly {
    func build(sessionStore: any ProfileSessionStore, navigator: any AppNavigating) -> some View {
        ProfileView(
            presenter: ProfilePresenter(
                interactor: ProfileInteractorImpl(sessionStore: sessionStore),
                router: ProfileRouterImpl(navigator: navigator)
            )
        )
    }
}
