import Foundation
import Observation

@MainActor
@Observable
final class RecipeImportViewModel {
    private(set) var recipes: [VkusVillRecipe] = []
    private(set) var isLoading = false
    private(set) var hasError = false
    private(set) var hasMore = false
    private let catalog: VkusVillCatalog

    init(catalog: VkusVillCatalog? = nil) {
        self.catalog = catalog ?? VkusVillCatalog()
    }

    func load(_ query: String, page: Int) async {
        guard !Task.isCancelled else { return }
        if page == 1 {
            recipes = []
            hasMore = false
        }
        hasError = false

        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            isLoading = false
            return
        }

        isLoading = true
        do {
            if page == 1 { try await Task.sleep(for: .milliseconds(350)) }
            let response = try await catalog.searchRecipes(String(term.prefix(255)), page: page)
            try Task.checkCancellation()
            var seen = Set(recipes.map(\.id))
            recipes.append(contentsOf: response.items.filter { seen.insert($0.id).inserted })
            hasMore = response.meta.hasMore
            isLoading = false
        } catch {
            guard !Task.isCancelled else { return }
            isLoading = false
            hasError = true
        }
    }
}
