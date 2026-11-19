import Combine
import Foundation

@MainActor
final class RecipeDetailPresenter: RecipeDetailViewOutput {
    @Published private(set) var state = RecipeDetailViewState()
    private let id: UUID
    private let interactor: any RecipeDetailInteractor
    private let router: any RecipeDetailRouter

    init(id: UUID, interactor: any RecipeDetailInteractor, router: any RecipeDetailRouter) {
        self.id = id
        self.interactor = interactor
        self.router = router
    }

    func load() {
        do {
            guard let recipe = try interactor.recipe(id: id) else {
                state.error = RecipeStoreError.notFound.localizedDescription
                return
            }
            state.title = recipe.title
            state.ingredients = recipe.ingredients
            state.steps = recipe.steps
            state.cookingTimeMinutes = recipe.cookingTimeMinutes
            state.isLoaded = true
        } catch {
            state.error = error.localizedDescription
        }
    }

    func edit() {
        router.editRecipe(id: id)
    }

    func delete() {
        do {
            try interactor.delete(id: id)
            router.goBack()
        } catch {
            state.error = error.localizedDescription
        }
    }

    func clearError() {
        state.error = nil
    }
}
