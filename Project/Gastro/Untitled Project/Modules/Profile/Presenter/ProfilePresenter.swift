import Combine
import Foundation

@MainActor
final class ProfilePresenter: ProfileViewOutput {
    @Published private(set) var state = ProfileViewState()
    private let interactor: any ProfileInteractor
    private let router: any ProfileRouter

    init(interactor: any ProfileInteractor, router: any ProfileRouter) {
        self.interactor = interactor
        self.router = router
    }

    func load() {
        state.username = interactor.currentUsername
    }

    func setName(_ value: String) {
        state.inputName = value
    }

    func setPassword(_ value: String) {
        state.inputPassword = value
    }

    func signIn() {
        do {
            try interactor.signIn(name: state.inputName, password: state.inputPassword)
            state.username = interactor.currentUsername
            state.inputPassword = ""
            state.error = nil
        } catch {
            state.error = error.localizedDescription
        }
    }

    func signOut() {
        interactor.signOut()
        state.username = nil
        state.inputName = ""
        state.inputPassword = ""
    }

    func showNetworkExamples() {
        router.showNetworkExamples()
    }

    func showRecipes() {
        router.showRecipes()
    }

    func clearError() {
        state.error = nil
    }
}
