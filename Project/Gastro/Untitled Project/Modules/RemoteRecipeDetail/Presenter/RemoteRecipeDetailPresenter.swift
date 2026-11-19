import Combine
import Foundation

@MainActor
final class RemoteRecipeDetailPresenter: RemoteRecipeDetailViewOutput {
    @Published private(set) var state = RemoteRecipeDetailViewState()
    private let id: Int
    private let interactor: any RemoteRecipeDetailInteractor
    private let router: any RemoteRecipeDetailRouter

    init(id: Int, interactor: any RemoteRecipeDetailInteractor, router: any RemoteRecipeDetailRouter) {
        self.id = id
        self.interactor = interactor
        self.router = router
    }

    func load() async {
        guard !state.isLoaded, !state.isLoading else { return }
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }

        do {
            let recipe = try await interactor.recipe(id: id)
            try Task.checkCancellation()
            state.title = recipe.name
            state.ingredients = recipe.ingredients
            state.steps = recipe.instructions
            state.imageURL = recipe.image
            state.cookingTimeMinutes = recipe.totalTimeMinutes
            state.isLoaded = true
        } catch is CancellationError {
            // The user left this screen before the response arrived.
        } catch {
            state.error = error.localizedDescription
        }
    }

    func goBack() {
        router.goBack()
    }
}
