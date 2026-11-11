import Foundation
import SwiftData

protocol RecipeRepositoryProtocol {

    func fetchRecipes() async throws -> [Recipe]

    func fetchRecipe(id: Int) async throws -> Recipe

    func isFavorite(id: Int) throws -> Bool

    func toggleFavorite(_ recipe: Recipe) throws

    func favoriteIDs() throws -> Set<Int>

    func addRecipe(_ recipe: Recipe) throws

    func updateRecipe(
        _ recipe: Recipe,
        name: String,
        ingredients: [String],
        instructions: [String],
        servings: Int,
        difficulty: String,
        cuisine: String
    ) throws

    func deleteRecipe(id: Int) throws
}

@MainActor
final class RecipeRepository: RecipeRepositoryProtocol {

    private let api: RecipeAPIProtocol
    private let storage: RecipeStorage

    init(
        api: RecipeAPIProtocol,
        context: ModelContext
    ) {
        self.api = api
        self.storage = RecipeStorage(
            context: context
        )
    }

    func fetchRecipes() async throws -> [Recipe] {

        do {

            let recipes = try await api.fetchRecipes()

            for recipe in recipes {
                try storage.saveOrUpdate(recipe)
            }

            return recipes

        } catch let networkError {

            do {

                let storedRecipes =
                    try storage.fetchRecipes()

                if !storedRecipes.isEmpty {

                    return storedRecipes.map {
                        storage.convertToRecipe($0)
                    }
                }

            } catch let storageError {

                throw RepositoryError.storageError(
                    storageError.localizedDescription
                )
            }

            throw networkError
        }
    }

 
    func fetchRecipe(id: Int) async throws -> Recipe {

        do {

            let recipe =
                try await api.fetchRecipe(id: id)

            try storage.saveOrUpdate(recipe)

            return recipe

        } catch {

            if let storedRecipe =
                try storage.fetchRecipe(id: id) {

                return storage.convertToRecipe(
                    storedRecipe
                )
            }

            throw error
        }
    }

    func isFavorite(id: Int) throws -> Bool {

        guard let recipe =
                try storage.fetchRecipe(id: id)
        else {
            return false
        }

        return recipe.isFavorite
    }

    func toggleFavorite(
        _ recipe: Recipe
    ) throws {

        if try storage.fetchRecipe(
            id: recipe.id
        ) == nil {

            try storage.addRecipe(recipe)
        }

        try storage.toggleFavorite(
            id: recipe.id
        )
    }
    

    func favoriteIDs() throws -> Set<Int> {

        let favorites =
            try storage.fetchFavoriteRecipes()

        return Set(
            favorites.map {
                $0.recipeID
            }
        )
    }


    func addRecipe(
        _ recipe: Recipe
    ) throws {

        try storage.addRecipe(recipe)
    }

    func updateRecipe(
        _ recipe: Recipe,
        name: String,
        ingredients: [String],
        instructions: [String],
        servings: Int,
        difficulty: String,
        cuisine: String
    ) throws {

        try storage.updateRecipe(
            id: recipe.id,
            name: name,
            ingredients: ingredients,
            instructions: instructions,
            servings: servings,
            difficulty: difficulty,
            cuisine: cuisine
        )
    }

    func deleteRecipe(
        id: Int
    ) throws {

        try storage.deleteRecipe(
            id: id
        )
    }
}


enum RepositoryError: LocalizedError {

    case storageError(String)

    var errorDescription: String? {

        switch self {

        case .storageError(let message):
            return "Ошибка локального хранилища: \(message)"
        }
    }
}
