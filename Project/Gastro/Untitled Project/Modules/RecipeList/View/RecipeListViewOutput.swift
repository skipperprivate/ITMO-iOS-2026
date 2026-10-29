import Combine
import Foundation

@MainActor
protocol RecipeListViewOutput: ObservableObject {
    var state: RecipeListViewState { get }

    func load()

    func loadRemote(force: Bool) async

    func delete(id: UUID)

    func showRecipe(id: RecipeRowID)

    func showNewRecipe()

    func clearError()
}
