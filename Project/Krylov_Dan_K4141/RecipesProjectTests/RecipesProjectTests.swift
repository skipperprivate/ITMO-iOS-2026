import XCTest
import SwiftData
@testable import RecipesProject

class RecipesProjectTests: XCTestCase {

    @MainActor
    func testSearchAndCategoryFilter() throws {
        let context = try makeContext()
        let defaults = try makeDefaults("searchTest")
        let viewModel = RecipeListViewModel(defaults: defaults)
        let omelet = makeRecipe("Омлет", "Яйца\nМолоко", .breakfast, in: context)
        let soup = makeRecipe("Борщ", "Свёкла\nКапуста", .lunch, in: context)

        viewModel.searchText = "яйц"
        XCTAssertTrue(viewModel.matches(omelet))
        XCTAssertFalse(viewModel.matches(soup))

        viewModel.searchText = ""
        viewModel.selectedCategory = .lunch
        XCTAssertFalse(viewModel.matches(omelet))
        XCTAssertTrue(viewModel.matches(soup))
    }

    @MainActor
    func testFavoritesFilterIsSaved() throws {
        let context = try makeContext()
        let defaults = try makeDefaults("favoritesTest")
        let viewModel = RecipeListViewModel(defaults: defaults)
        let favorite = makeRecipe("Сырники", "Творог", .breakfast, favorite: true, in: context)
        let usual = makeRecipe("Каша", "Овсянка", .breakfast, in: context)

        viewModel.favoritesOnly = true
        let sections = viewModel.sections([favorite, usual])
        var titles: [String] = []
        for section in sections {
            for recipe in section.recipes {
                titles.append(recipe.title)
            }
        }
        XCTAssertEqual(titles, ["Сырники"])

        let reopened = RecipeListViewModel(defaults: defaults)
        XCTAssertTrue(reopened.favoritesOnly)
    }

    @MainActor
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Recipe.self, configurations: config)
        return ModelContext(container)
    }

    @MainActor
    private func makeRecipe(_ title: String, _ ingredients: String, _ category: MealType,
                            favorite: Bool = false, in context: ModelContext) -> Recipe {
        let recipe = Recipe(title: title, ingredients: ingredients, steps: "", category: category)
        recipe.isFavorite = favorite
        context.insert(recipe)
        return recipe
    }

    private func makeDefaults(_ name: String) throws -> UserDefaults {
        // Тест использует отдельное хранилище с заранее заданным именем.
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
