import Combine
import Foundation

@MainActor
final class RecipeListPresenter: RecipeListViewOutput {
    @Published private(set) var state = RecipeListViewState()
    private let interactor: any RecipeListInteractor
    private let router: any RecipeListRouter
    private var localRows: [RecipeRowState] = []
    private var remoteRows: [RecipeRowState] = []
    private var hasLoadedRemote = false

    init(interactor: any RecipeListInteractor, router: any RecipeListRouter) {
        self.interactor = interactor
        self.router = router
    }

    func load() {
        do {
            localRows = try interactor.recipes().map {
                RecipeRowState(
                    id: .local($0.id),
                    title: $0.title,
                    ingredientCount: $0.ingredients.count,
                    cookingTimeMinutes: $0.cookingTimeMinutes
                )
            }
            updateRows()
            state.error = nil
        } catch {
            state.error = error.localizedDescription
        }
    }

    func loadRemote(force: Bool = false) async {
        guard !state.isLoadingRemote, force || !hasLoadedRemote else { return }
        state.isLoadingRemote = true
        state.remoteError = nil
        defer { state.isLoadingRemote = false }

        do {
            let recipes = try await interactor.remoteRecipes()
            try Task.checkCancellation()
            remoteRows = recipes.map {
                RecipeRowState(
                    id: .remote($0.id),
                    title: $0.name,
                    ingredientCount: $0.ingredients.count,
                    cookingTimeMinutes: $0.totalTimeMinutes
                )
            }
            hasLoadedRemote = true
            updateRows()
        } catch is CancellationError {
            // The view went away while the request was in progress.
        } catch {
            state.remoteError = error.localizedDescription
        }
    }

    func delete(id: UUID) {
        do {
            try interactor.delete(id: id)
            load()
        } catch {
            state.error = error.localizedDescription
        }
    }

    func showRecipe(id: RecipeRowID) {
        switch id {
            case .local(let id): router.showRecipe(id: id)
            case .remote(let id): router.showRemoteRecipe(id: id)
        }
    }

    func showNewRecipe() {
        router.showNewRecipe()
    }

    func clearError() {
        state.error = nil
    }

    private func updateRows() {
        state.recipes = localRows + remoteRows
    }
}
