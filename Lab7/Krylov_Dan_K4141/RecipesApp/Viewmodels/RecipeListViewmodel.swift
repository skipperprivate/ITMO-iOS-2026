import Foundation
import SwiftData
import Observation

enum SortOption: String, CaseIterable, Identifiable {
    case newest, oldest, titleAZ, titleZA

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newest:
            return "Сначала новые"
        case .oldest:
            return "Сначала старые"
        case .titleAZ:
            return "По названию А–Я"
        case .titleZA:
            return "По названию Я–А"
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
class RecipeListViewModel {
    private let defaults: UserDefaults

    var isLoading = false
    var errorMessage: String?
    var searchText = ""
    var selectedCategory: MealType?

    var sortOption: SortOption {
        didSet {
            defaults.set(sortOption.rawValue, forKey: "sortOption")
        }
    }

    var favoritesOnly: Bool {
        didSet {
            defaults.set(favoritesOnly, forKey: "favoritesOnly")
        }
    }

    var showError: Bool {
        get {
            return errorMessage != nil
        }
        set {
            if !newValue {
                errorMessage = nil
            }
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        sortOption = SortOption(rawValue: defaults.string(forKey: "sortOption") ?? "") ?? .newest
        favoritesOnly = defaults.bool(forKey: "favoritesOnly")
    }

    func matches(_ recipe: Recipe) -> Bool {
        // Если хотя бы один фильтр не подходит, рецепт не показываем.
        if let category = selectedCategory, recipe.category != category {
            return false
        }
        if favoritesOnly && !recipe.isFavorite {
            return false
        }

        let query = searchText.trimmingCharacters(in: .whitespaces)
        if query.isEmpty {
            return true
        }
        if recipe.title.localizedCaseInsensitiveContains(query) {
            return true
        }
        return recipe.ingredients.localizedCaseInsensitiveContains(query)
    }

    func sections(_ recipes: [Recipe]) -> [RecipeSection] {
        var matchingRecipes: [Recipe] = []
        for recipe in recipes {
            if !matches(recipe) {
                continue
            }
            matchingRecipes.append(recipe)
        }
        let sortedRecipes = sort(matchingRecipes)

        var result: [RecipeSection] = []
        for category in MealType.allCases {
            var categoryRecipes: [Recipe] = []
            for recipe in sortedRecipes {
                if recipe.category != category {
                    continue
                }
                categoryRecipes.append(recipe)
            }
            if !categoryRecipes.isEmpty {
                result.append(RecipeSection(type: category, recipes: categoryRecipes))
            }
        }
        return result
    }

    func delete(_ recipe: Recipe, context: ModelContext) {
        context.delete(recipe)
    }

    func loadRandomRecipe(context: ModelContext) async {
        isLoading = true
        defer {
            isLoading = false
        }

        do {
            let loaded = try await RecipeAPI.fetchRandom()
            save(loaded, context: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadOnePerCategory(context: ModelContext) async {
        isLoading = true
        defer {
            isLoading = false
        }

        let loaded = await RecipeAPI.fetchOnePerCategory()

        if loaded.isEmpty {
            errorMessage = "Не удалось загрузить рецепты"
        }
        for recipe in loaded {
            save(recipe, context: context)
        }
    }

    private func sort(_ recipes: [Recipe]) -> [Recipe] {
        switch sortOption {
        case .newest: return recipes.sorted { first, second in first.createdAt > second.createdAt }
        case .oldest: return recipes.sorted { first, second in first.createdAt < second.createdAt }
        case .titleAZ: return recipes.sorted { first, second in first.title < second.title }
        case .titleZA: return recipes.sorted { first, second in first.title > second.title }
        }
    }

    private func save(_ loaded: LoadedRecipe, context: ModelContext) {
        let recipe = Recipe(title: loaded.title, ingredients: loaded.ingredients,
                            steps: loaded.steps, category: loaded.category)
        context.insert(recipe)
    }
}
