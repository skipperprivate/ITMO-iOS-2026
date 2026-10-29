import Combine
import Foundation

@MainActor
protocol RecipeListInteractor {
    func recipes() throws -> [Recipe]

    func remoteRecipes() async throws -> [RemoteRecipe]

    func delete(id: UUID) throws
}
