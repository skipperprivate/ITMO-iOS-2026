import Combine
import Foundation

@MainActor
protocol RecipeListInteractor {
    func favorites() throws -> [RecipeRowState]

    func saveFavorites(_ recipes: [RecipeRowState]) throws

    func recipes() throws -> [Recipe]

    func remoteRecipes() async throws -> [RemoteRecipe]

    func delete(id: UUID) throws
}
