import Combine
import Foundation

@MainActor
protocol RemoteRecipeDetailInteractor {
    func recipe(id: Int) async throws -> RemoteRecipe
}
