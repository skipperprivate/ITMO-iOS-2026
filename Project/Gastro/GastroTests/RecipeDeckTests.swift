import XCTest

@testable import Untitled_Project

@MainActor
final class RecipeDeckTests: XCTestCase {
    func testFavoritesSurviveStoreRecreationAndDoNotDuplicate() async throws {
        let suite = "gastro.favorites.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = UserDefaultsFavoriteRecipeStore(defaults: defaults)
        let interactor = DeckInteractor(store: store)
        let presenter = RecipeListPresenter(interactor: interactor, router: DeckRouter())
        presenter.load()
        let recipe = RecipeRowState(id: .remote(1), title: "Омлет", ingredientCount: 2, cookingTimeMinutes: 10)
        presenter.toggleFavorite(recipe)
        XCTAssertEqual(try UserDefaultsFavoriteRecipeStore(defaults: defaults).load(), [recipe])
        presenter.toggleFavorite(recipe)
        XCTAssertTrue(try store.load().isEmpty)
    }

    func testSkipAndFavoriteHaveDifferentEffectsAndDeckCanRestart() async {
        let first = RecipeRowState(id: .remote(1), title: "Первый", ingredientCount: 1, cookingTimeMinutes: nil)
        let second = RecipeRowState(id: .remote(2), title: "Второй", ingredientCount: 1, cookingTimeMinutes: nil)
        var state = RecipeListViewState()
        state.recipes = [first, second]
        state.skippedIDs.insert(first.id)
        XCTAssertEqual(state.recommendations, [second])
        XCTAssertTrue(state.favorites.isEmpty)
        state.favorites = [second]
        XCTAssertTrue(state.recommendations.isEmpty)
        state.skippedIDs.removeAll()
        XCTAssertEqual(state.recommendations, [first])
    }
}

@MainActor
private final class DeckInteractor: RecipeListInteractor {
    let store: any FavoriteRecipeStore
    init(store: any FavoriteRecipeStore) { self.store = store }
    func favorites() throws -> [RecipeRowState] { try store.load() }
    func saveFavorites(_ recipes: [RecipeRowState]) throws { try store.save(recipes) }
    func recipes() throws -> [Recipe] { [] }
    func remoteRecipes() async throws -> [RemoteRecipe] { [] }
    func delete(id: UUID) throws {}
}

@MainActor
private final class DeckRouter: RecipeListRouter {
    func showRecipe(id: UUID) {}
    func showRemoteRecipe(id: Int) {}
    func showNewRecipe() {}
}
