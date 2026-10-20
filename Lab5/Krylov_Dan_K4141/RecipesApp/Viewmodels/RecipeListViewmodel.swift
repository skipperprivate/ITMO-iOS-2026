import Foundation
import SwiftData
import Observation

enum SortOption: String, CaseIterable, Identifiable {
    case newest, oldest, titleAZ, titleZA

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newest: "Сначала новые"
        case .oldest: "Сначала старые"
        case .titleAZ: "По названию А–Я"
        case .titleZA: "По названию Я–А"
        }
    }
}

struct RecipeSection: Identifiable {
    let type: MealType
    let recipes: [Recipe]
    var id: MealType { type }
}

@MainActor
@Observable
final class RecipeListViewModel {
    private let sortKey = "sortOption"

    var isLoading = false
    var errorMessage: String?

    var sortOption: SortOption {
        didSet { UserDefaults.standard.set(sortOption.rawValue, forKey: sortKey) }
    }

    var showError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: sortKey) ?? ""
        sortOption = SortOption(rawValue: saved) ?? .newest
    }

    func sections(_ recipes: [Recipe]) -> [RecipeSection] {
        let sorted = sort(recipes)
        return MealType.allCases.compactMap { type in
            let items = sorted.filter { $0.category == type }
            return items.isEmpty ? nil : RecipeSection(type: type, recipes: items)
        }
    }

    func delete(_ recipe: Recipe, context: ModelContext) {
        context.delete(recipe)
    }

    func loadRandomRecipe(context: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let loaded = try await RecipeAPI.fetchRandom()
            save(loaded, context: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadOnePerCategory(context: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        let start = ContinuousClock.now
        let loaded = await RecipeAPI.fetchOnePerCategory()
        print("Загружено \(loaded.count) за \(ContinuousClock.now - start)")

        if loaded.isEmpty { errorMessage = "Не удалось загрузить рецепты" }
        loaded.forEach { save($0, context: context) }
    }

    private func sort(_ recipes: [Recipe]) -> [Recipe] {
        switch sortOption {
        case .newest: recipes.sorted { $0.createdAt > $1.createdAt }
        case .oldest: recipes.sorted { $0.createdAt < $1.createdAt }
        case .titleAZ: recipes.sorted { $0.title < $1.title }
        case .titleZA: recipes.sorted { $0.title > $1.title }
        }
    }

    private func save(_ loaded: LoadedRecipe, context: ModelContext) {
        let recipe = Recipe(title: loaded.title, ingredients: loaded.ingredients,
                            steps: loaded.steps, category: loaded.category)
        context.insert(recipe)
    }
}
