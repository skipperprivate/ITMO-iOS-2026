import Combine
import Foundation

@MainActor
final class HomePresenter: HomeViewOutput {
    @Published private(set) var state = HomeViewState()
    private let interactor: any HomeInteractor
    private let router: any HomeRouter

    init(interactor: any HomeInteractor, router: any HomeRouter) {
        self.interactor = interactor
        self.router = router
    }

    func load() {
        do {
            state.recipeCount = try interactor.recipeCount()
        } catch {
            state.error = error.localizedDescription
        }
    }

    func showRecipes() {
        router.showRecipes()
    }

    func showProfile() {
        router.showProfile()
    }

    func clearError() {
        state.error = nil
    }
}
