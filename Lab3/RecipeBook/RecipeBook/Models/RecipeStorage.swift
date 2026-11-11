import Foundation
import SwiftData


@Model
final class StoredRecipe {
    
    @Attribute(.unique)
    var recipeID: Int
    
    var name: String
    
    var ingredients: [String]
    var instructions: [String]
    
    var prepTimeMinutes: Int
    var cookTimeMinutes: Int
    
    var servings: Int
    var difficulty: String
    var cuisine: String
    
    var caloriesPerServing: Int
    var image: String
    var tags: [String]
    
    var isFavorite: Bool
    
    var updatedAt: Date
    
    init(
        recipeID: Int,
        name: String,
        ingredients: [String],
        instructions: [String],
        prepTimeMinutes: Int,
        cookTimeMinutes: Int,
        servings: Int,
        difficulty: String,
        cuisine: String,
        caloriesPerServing: Int,
        image: String,
        tags: [String],
        isFavorite: Bool = false,
        updatedAt: Date = .now
    ) {
        self.recipeID = recipeID
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.servings = servings
        self.difficulty = difficulty
        self.cuisine = cuisine
        self.caloriesPerServing = caloriesPerServing
        self.image = image
        self.tags = tags
        self.isFavorite = isFavorite
        self.updatedAt = updatedAt
    }
}



@MainActor
final class RecipeStorage {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    
    
    func addRecipe(_ recipe: Recipe) throws {
        if try fetchRecipe(id: recipe.id) != nil {
            return
        }

        let storedRecipe = StoredRecipe(
            recipeID: recipe.id,
            name: recipe.name,
            ingredients: recipe.ingredients,
            instructions: recipe.instructions,
            prepTimeMinutes: recipe.prepTimeMinutes,
            cookTimeMinutes: recipe.cookTimeMinutes,
            servings: recipe.servings,
            difficulty: recipe.difficulty,
            cuisine: recipe.cuisine,
            caloriesPerServing: recipe.caloriesPerServing,
            image: recipe.image,
            tags: recipe.tags
        )

        context.insert(storedRecipe)

        try save()
    }
    
    
    
    func fetchRecipes() throws -> [StoredRecipe] {
        
        let descriptor = FetchDescriptor<StoredRecipe>(
            sortBy: [
                SortDescriptor(\.name)
            ]
        )
        
        return try context.fetch(descriptor)
    }
    
    
    func fetchRecipe(id: Int) throws -> StoredRecipe? {
        
        let descriptor = FetchDescriptor<StoredRecipe>(
            predicate: #Predicate<StoredRecipe> {
                $0.recipeID == id
            }
        )
        
        return try context.fetch(descriptor).first
    }
    
    
    func fetchFavoriteRecipes() throws -> [StoredRecipe] {
        
        let descriptor = FetchDescriptor<StoredRecipe>(
            predicate: #Predicate<StoredRecipe> {
                $0.isFavorite == true
            },
            sortBy: [
                SortDescriptor(\.name)
            ]
        )
        
        return try context.fetch(descriptor)
    }
    

    
    func updateRecipe(
        id: Int,
        name: String,
        ingredients: [String],
        instructions: [String],
        servings: Int,
        difficulty: String,
        cuisine: String
    ) throws {
        
        guard let recipe = try fetchRecipe(id: id) else {
            return
        }
        
        recipe.name = name
        recipe.ingredients = ingredients
        recipe.instructions = instructions
        recipe.servings = servings
        recipe.difficulty = difficulty
        recipe.cuisine = cuisine
        recipe.updatedAt = .now
        
        try save()
    }
    
    
    func toggleFavorite(id: Int) throws {
        guard let recipe = try fetchRecipe(id: id) else {
            return
        }
        recipe.isFavorite.toggle()
        recipe.updatedAt = .now
        try save()
    }
    
    
  
    func deleteRecipe(id: Int) throws {
        
        guard let recipe = try fetchRecipe(id: id) else {
            return
        }
        
        context.delete(recipe)
        
        try save()
    }
    

    func saveOrUpdate(_ recipe: Recipe) throws {
        
        if let existingRecipe = try fetchRecipe(id: recipe.id) {
            
            existingRecipe.name = recipe.name
            existingRecipe.ingredients = recipe.ingredients
            existingRecipe.instructions = recipe.instructions
            existingRecipe.prepTimeMinutes = recipe.prepTimeMinutes
            existingRecipe.cookTimeMinutes = recipe.cookTimeMinutes
            existingRecipe.servings = recipe.servings
            existingRecipe.difficulty = recipe.difficulty
            existingRecipe.cuisine = recipe.cuisine
            existingRecipe.caloriesPerServing = recipe.caloriesPerServing
            existingRecipe.image = recipe.image
            existingRecipe.tags = recipe.tags
            existingRecipe.updatedAt = .now
            
        } else {
            
            let newRecipe = StoredRecipe(
                recipeID: recipe.id,
                name: recipe.name,
                ingredients: recipe.ingredients,
                instructions: recipe.instructions,
                prepTimeMinutes: recipe.prepTimeMinutes,
                cookTimeMinutes: recipe.cookTimeMinutes,
                servings: recipe.servings,
                difficulty: recipe.difficulty,
                cuisine: recipe.cuisine,
                caloriesPerServing: recipe.caloriesPerServing,
                image: recipe.image,
                tags: recipe.tags
            )
            
            context.insert(newRecipe)
        }
        
        try save()
    }

    
    func convertToRecipe(_ storedRecipe: StoredRecipe) -> Recipe {
        
        Recipe(
            id: storedRecipe.recipeID,
            name: storedRecipe.name,
            ingredients: storedRecipe.ingredients,
            instructions: storedRecipe.instructions,
            prepTimeMinutes: storedRecipe.prepTimeMinutes,
            cookTimeMinutes: storedRecipe.cookTimeMinutes,
            servings: storedRecipe.servings,
            difficulty: storedRecipe.difficulty,
            cuisine: storedRecipe.cuisine,
            caloriesPerServing: storedRecipe.caloriesPerServing,
            image: storedRecipe.image,
            tags: storedRecipe.tags
        )
    }
    
    
    
    private func save() throws {
        try context.save()
    }
}
