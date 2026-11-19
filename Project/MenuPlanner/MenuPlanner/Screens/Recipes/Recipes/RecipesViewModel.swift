import Foundation
import Observation
import SwiftData

enum RecipeFilter: String, CaseIterable, Identifiable {
    case all = "Все блюда"
    case quick = "До 30 мин"
    var id: Self { self }
}

enum RecipeSort: String, CaseIterable, Identifiable {
    case collection = "По умолчанию"
    case name = "По названию"
    case duration = "По времени приготовления"
    var id: Self { self }
}

@MainActor
@Observable
final class RecipesViewModel {
    var searchText = ""
    var filter: RecipeFilter = .all
    var sort: RecipeSort = .collection
    var favoritesOnly = false
    var isPresentingEditor = false
    var errorMessage: String?
    private var hasLoaded = false

    func load(in context: ModelContext) {
        guard !hasLoaded else { return }
        do {
            let examples = try context.fetch(FetchDescriptor<Recipe>(predicate: #Predicate { $0.isBuiltIn }))
            for recipe in examples { context.delete(recipe) }
            if !examples.isEmpty { try context.save() }
            hasLoaded = true
        } catch {
            context.rollback()
            errorMessage = "Не удалось обновить рецепты. Попробуй открыть вкладку ещё раз."
        }
    }

    func visibleRecipes(from recipes: [Recipe]) -> [Recipe] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = recipes.filter { recipe in
            guard !recipe.isBuiltIn else { return false }
            let matchesFilter = switch filter {
            case .all: true
            case .quick: recipe.durationMinutes <= 30
            }
            let matchesSearch = query.isEmpty
                || recipe.name.localizedStandardContains(query)
                || recipe.ingredients.contains { $0.ingredient.name.localizedStandardContains(query) }
            return matchesFilter && matchesSearch && (!favoritesOnly || recipe.isFavorite)
        }

        return filtered.sorted { lhs, rhs in
            switch sort {
            case .duration:
                if lhs.durationMinutes != rhs.durationMinutes {
                    return lhs.durationMinutes < rhs.durationMinutes
                }
            case .collection, .name:
                break
            }
            let comparison = lhs.name.localizedStandardCompare(rhs.name)
            if comparison != .orderedSame { return comparison == .orderedAscending }
            return lhs.id.uuidString < rhs.id.uuidString
        }
    }
}
