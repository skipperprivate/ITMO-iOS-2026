import Foundation

nonisolated struct RecipeResponse: Decodable, Sendable {
    let id: Int
    let name: String
    let ingredients: [String]
    let instructions: [String]
    let image: URL?
    let prepTimeMinutes: Int?
    let cookTimeMinutes: Int?

    var recipe: RemoteRecipe {
        RemoteRecipe(
            id: id,
            name: name,
            ingredients: ingredients,
            instructions: instructions,
            image: image,
            prepTimeMinutes: prepTimeMinutes,
            cookTimeMinutes: cookTimeMinutes
        )
    }
}
