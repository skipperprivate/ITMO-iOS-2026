import Combine
import Foundation

@MainActor
protocol RecipeListViewOutput: ObservableObject {
    var state: RecipeListViewState { get }

    func toggleFavorite(_ recipe: RecipeRowState)

    func skip(_ recipe: RecipeRowState)

    func restartDeck()

    func load()

    func loadRemote(force: Bool) async

    func delete(id: UUID)

    func showRecipe(id: RecipeRowID)

    func showNewRecipe()

    func clearError()
}
