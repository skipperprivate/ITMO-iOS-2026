//
//  FavoriteRecipe.swift
//  RecipeBox
//
//  Created by nktmahov on 05.10.26.
//

import Foundation
import SwiftData

@Model
final class FavoriteRecipe {
    @Attribute(.unique) var apiID: String
    var title: String
    var instructions: String
    var imageURLString: String?
    var category: String?
    var area: String?
    var ingredientsData: Data
    var savedAt: Date

    init(recipe: APIRecipe) {
        apiID = recipe.id
        title = recipe.title
        instructions = recipe.instructions
        imageURLString = recipe.imageURL?.absoluteString
        category = recipe.category
        area = recipe.area
        ingredientsData = (try? JSONEncoder().encode(recipe.ingredients)) ?? Data()
        savedAt = .now
    }

    var apiRecipe: APIRecipe {
        APIRecipe(
            id: apiID,
            title: title,
            instructions: instructions,
            imageURL: imageURLString.flatMap(URL.init(string:)),
            category: category,
            area: area,
            ingredients: (try? JSONDecoder().decode([Ingredient].self, from: ingredientsData)) ?? []
        )
    }
}
