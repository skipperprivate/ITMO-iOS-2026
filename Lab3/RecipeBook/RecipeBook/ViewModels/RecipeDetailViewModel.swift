import Foundation
import Combine

@MainActor
final class RecipeDetailViewModel: ObservableObject {
    @Published private(set) var recipe: Recipe?
    @Published private(set) var isFavorite = false
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let recipeID: Int
    private let repository: RecipeRepositoryProtocol

    init(recipeID: Int, repository: RecipeRepositoryProtocol) {
        self.recipeID = recipeID
        self.repository = repository
    }

    func load() async {
        guard recipe == nil else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            async let r = repository.fetchRecipe(id: recipeID)
            async let f = repository.isFavorite(id: recipeID)
            recipe = try await r
            isFavorite = try await f
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavorite() {
        guard let recipe else { return }
        do {
            try repository.toggleFavorite(recipe)
            isFavorite = try repository.isFavorite(id: recipe.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
