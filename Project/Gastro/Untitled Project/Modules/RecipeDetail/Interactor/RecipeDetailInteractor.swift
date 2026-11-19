import Combine
import Foundation

@MainActor
protocol RecipeDetailInteractor {
    func recipe(id: UUID) throws -> Recipe?

    func delete(id: UUID) throws
}
