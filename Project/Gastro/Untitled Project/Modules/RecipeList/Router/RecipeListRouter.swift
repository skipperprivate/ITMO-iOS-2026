import Combine
import Foundation

@MainActor
protocol RecipeListRouter {
    func showRecipe(id: UUID)

    func showRemoteRecipe(id: Int)

    func showNewRecipe()
}
