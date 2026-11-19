import Foundation

@MainActor
protocol FavoriteRecipeStore {
    func load() throws -> [RecipeRowState]
    func save(_ recipes: [RecipeRowState]) throws
}

@MainActor
final class UserDefaultsFavoriteRecipeStore: FavoriteRecipeStore {
    private let defaults: UserDefaults
    private let key = "gastro.favoriteRecipes.v1"

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func load() throws -> [RecipeRowState] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([RecipeRowState].self, from: data)
    }

    func save(_ recipes: [RecipeRowState]) throws {
        defaults.set(try JSONEncoder().encode(recipes), forKey: key)
    }
}
