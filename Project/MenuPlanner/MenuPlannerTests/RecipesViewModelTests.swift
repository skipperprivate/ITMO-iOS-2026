import XCTest
@testable import MenuPlanner

@MainActor
final class RecipesViewModelTests: XCTestCase {
    func testSearchMatchesIngredientIgnoringCaseAndSurroundingWhitespace() {
        let fish = recipe("Ужин", ingredient: "Лосось")
        let soup = recipe("Суп", ingredient: "Картофель")
        let viewModel = RecipesViewModel()
        viewModel.searchText = "  ЛОСОСЬ \n"
        XCTAssertEqual(viewModel.visibleRecipes(from: [soup, fish]).map(\.id), [fish.id])
    }

    func testSearchMatchesRecipeNameAndReturnsNoUnrelatedRecipes() {
        let soup = recipe("Томатный суп")
        let viewModel = RecipesViewModel()
        viewModel.searchText = "томатный"
        XCTAssertEqual(viewModel.visibleRecipes(from: [soup]).map(\.id), [soup.id])
        viewModel.searchText = "несуществующее блюдо"
        XCTAssertTrue(viewModel.visibleRecipes(from: [soup]).isEmpty)
    }

    func testQuickFilterIncludesThirtyMinutesAndExcludesLongerRecipes() {
        let quick = recipe("Быстрое", duration: 30)
        let slow = recipe("Долгое", duration: 31)
        let viewModel = RecipesViewModel()
        viewModel.filter = .quick
        XCTAssertEqual(viewModel.visibleRecipes(from: [slow, quick]).map(\.id), [quick.id])
    }

    func testSearchQuickAndFavoriteFiltersApplyTogether() {
        let match = recipe("Суп", duration: 20, favorite: true)
        let slow = recipe("Суп долгий", duration: 45, favorite: true)
        let ordinary = recipe("Суп обычный", duration: 20)
        let unrelated = recipe("Салат", duration: 20, favorite: true)
        let viewModel = RecipesViewModel()
        viewModel.searchText = "суп"
        viewModel.filter = .quick
        viewModel.favoritesOnly = true
        XCTAssertEqual(viewModel.visibleRecipes(from: [slow, ordinary, unrelated, match]).map(\.id), [match.id])
    }

    func testSortByDurationUsesNameForTiesAndExcludesBuiltInRecipes() {
        let a = recipe("А", duration: 20)
        let b = recipe("Б", duration: 20)
        let c = recipe("В", duration: 10)
        let builtIn = recipe("Пример", duration: 1)
        builtIn.isBuiltIn = true
        let viewModel = RecipesViewModel()
        viewModel.sort = .duration
        XCTAssertEqual(viewModel.visibleRecipes(from: [b, builtIn, a, c]).map(\.id), [c.id, a.id, b.id])
    }

    func testNameSortUsesIDForStableOrderingOfIdenticalNames() {
        let first = recipe("Суп")
        let second = recipe("Суп")
        let viewModel = RecipesViewModel()
        viewModel.sort = .name
        let expected = [first, second].sorted { $0.id.uuidString < $1.id.uuidString }.map(\.id)
        XCTAssertEqual(viewModel.visibleRecipes(from: [second, first]).map(\.id), expected)
    }

    private func recipe(_ name: String, ingredient: String = "Рис", duration: Int = 15,
                        favorite: Bool = false) -> Recipe {
        Recipe(name: name, recipeDescription: "", durationMinutes: duration, baseServings: 2,
               ingredients: [RecipeIngredient(ingredient: Ingredient(name: ingredient), quantity: 100)],
               isFavorite: favorite)
    }
}
