import XCTest
@testable import RecipeBook

@MainActor
final class RecipeBookTests: XCTestCase {
    

    func testTotalTime() {

        let recipe = makeRecipe(prep: 10, cook: 25)

       
        let total = recipe.totalTime

 
        XCTAssertEqual(total, 35, "Общее время должно быть суммой подготовки и готовки")
    }

    func testDifficultyTranslation() {
  
        let easyRecipe = makeRecipe(difficulty: "easy")
        let hardRecipe = makeRecipe(difficulty: "hard")

        
        let easyText = easyRecipe.difficultyText
        let hardText = hardRecipe.difficultyText


        XCTAssertEqual(easyText, "Легко", "Сложность 'easy' должна переводиться как 'Легко'")
        XCTAssertEqual(hardText, "Сложно", "Сложность 'hard' должна переводиться как 'Сложно'")
    }


    func testSearchFilter() async {
        let vm = HomeViewModel(repository: MockRepository())
        await vm.load()

 
        vm.searchText = "Паста"

 
        XCTAssertEqual(vm.filteredRecipes.count, 1, "Должен остаться только 1 рецепт")
        XCTAssertEqual(vm.filteredRecipes.first?.name, "Паста", "Должен остаться именно рецепт 'Паста'")
    }

    func testCuisineFilter() async {

        let vm = HomeViewModel(repository: MockRepository())
        await vm.load()

    
        vm.selectedCuisine = "Италия"

     
        XCTAssertEqual(vm.filteredRecipes.count, 1, "Должен остаться только 1 рецепт итальянской кухни")
        XCTAssertEqual(vm.filteredRecipes.first?.name, "Паста", "Должен остаться именно рецепт 'Паста'")
    }

 

    func testToggleFavorite() async throws { // Добавили throws
        let mockRepo = MockRepository()
        let vm = HomeViewModel(repository: mockRepo)
        await vm.load()
        
        // Убрали восклицательный знак
        let recipe = try await mockRepo.fetchRecipe(id: 1)

        vm.toggleFavorite(recipe)
        XCTAssertTrue(vm.isFavorite(recipe), "Рецепт должен быть добавлен в избранное")

        vm.toggleFavorite(recipe)
        XCTAssertFalse(vm.isFavorite(recipe), "Рецепт должен быть удалён из избранного")
    }

    private func makeRecipe(
        prep: Int = 10,
        cook: Int = 10,
        difficulty: String = "easy"
    ) -> Recipe {
        Recipe(
            id: 1,
            name: "Test",
            ingredients: [],
            instructions: [],
            prepTimeMinutes: prep,
            cookTimeMinutes: cook,
            servings: 2,
            difficulty: difficulty,
            cuisine: "Италия",
            caloriesPerServing: 300,
            image: "",
            tags: []
        )
    }
}



private final class MockRepository: RecipeRepositoryProtocol {
    
    private var storedFavoriteIDs: Set<Int> = []

    private let recipes: [Recipe] = [
        Recipe(id: 1, name: "Паста", ingredients: [], instructions: [], prepTimeMinutes: 10, cookTimeMinutes: 15, servings: 2, difficulty: "easy", cuisine: "Италия", caloriesPerServing: 500, image: "", tags: ["паста"]),
        Recipe(id: 2, name: "Суши", ingredients: [], instructions: [], prepTimeMinutes: 20, cookTimeMinutes: 10, servings: 2, difficulty: "medium", cuisine: "Япония", caloriesPerServing: 400, image: "", tags: ["суши"])
    ]

    func fetchRecipes() async throws -> [Recipe] { recipes }

    func fetchRecipe(id: Int) async throws -> Recipe {
        guard let recipe = recipes.first(where: { $0.id == id }) else {
            throw MockRepositoryError.recipeNotFound
        }
        return recipe
    }

    func isFavorite(id: Int) throws -> Bool {
        storedFavoriteIDs.contains(id)
    }

    func toggleFavorite(_ recipe: Recipe) throws {
        if storedFavoriteIDs.contains(recipe.id) {
            storedFavoriteIDs.remove(recipe.id)
        } else {
            storedFavoriteIDs.insert(recipe.id)
        }
    }

    func favoriteIDs() throws -> Set<Int> {
        storedFavoriteIDs
    }

    func addRecipe(_ recipe: Recipe) throws {}
    func updateRecipe(_ recipe: Recipe, name: String, ingredients: [String], instructions: [String], servings: Int, difficulty: String, cuisine: String) throws {}
    func deleteRecipe(id: Int) throws {}
}

private enum MockRepositoryError: Error {
    case recipeNotFound
}
