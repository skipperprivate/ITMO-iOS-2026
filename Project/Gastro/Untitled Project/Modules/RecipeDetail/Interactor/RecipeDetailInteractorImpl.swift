import Foundation

@MainActor
final class RecipeDetailInteractorImpl: RecipeDetailInteractor {
    private let repository: any RecipeRepository

    init(repository: any RecipeRepository) {
        self.repository = repository
    }

    func recipe(id: UUID) throws -> Recipe? {
        try repository.find(id: id)
    }

    func delete(id: UUID) throws {
        try repository.delete(id: id)
    }
}
