import Combine
import Foundation

@MainActor
protocol RecipeDetailRouter {
    func editRecipe(id: UUID)

    func goBack()
}
