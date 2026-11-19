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
            state.favorites = try interactor.favorites()
            localRows = try interactor.recipes().map {
                RecipeRowState(
                    id: .local($0.id),
                    title: $0.title,
                    ingredientCount: $0.ingredients.count,
                    cookingTimeMinutes: $0.cookingTimeMinutes,
                    ingredientSummary: $0.ingredients.prefix(3).joined(separator: ", ")
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
                    cookingTimeMinutes: $0.totalTimeMinutes,
                    image: $0.image,
                    ingredientSummary: $0.ingredients.prefix(3).joined(separator: ", ")
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
            let favorites = state.favorites.filter { $0.id != .local(id) }
            try interactor.saveFavorites(favorites)
            state.favorites = favorites
            try interactor.delete(id: id)
            load()
        } catch {
            state.error = error.localizedDescription
        }
    }

    func toggleFavorite(_ recipe: RecipeRowState) {
        var favorites = state.favorites
        if favorites.contains(where: { $0.id == recipe.id }) {
            favorites.removeAll { $0.id == recipe.id }
        } else {
            favorites.append(recipe)
        }
        do {
            try interactor.saveFavorites(favorites)
            state.favorites = favorites
        } catch {
            state.error = error.localizedDescription
        }
    }

    func skip(_ recipe: RecipeRowState) {
        state.skippedIDs.insert(recipe.id)
    }

    func restartDeck() {
        state.skippedIDs.removeAll()
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
