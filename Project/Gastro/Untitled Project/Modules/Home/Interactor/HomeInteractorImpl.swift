@MainActor
final class HomeInteractorImpl: HomeInteractor {
    private let repository: any RecipeRepository

    init(repository: any RecipeRepository) {
        self.repository = repository
    }

    func recipeCount() throws -> Int {
        try repository.fetchRecipes().count
    }
}
