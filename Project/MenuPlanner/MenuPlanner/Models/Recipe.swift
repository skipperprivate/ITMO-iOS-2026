//
//  Recipe.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import SwiftData
import Foundation

@Model
final class Recipe {
    private(set) var id: UUID
    var name: String
    var recipeDescription: String
    var durationMinutes: Int
    private(set) var baseServings: Int
    var photoData: Data?
    var sourceURL: URL?
    var isBuiltIn: Bool = false
    var isFavorite: Bool = false
    
    @Relationship(deleteRule:  .cascade)
    var ingredients: [RecipeIngredient]
    
    init (
        id: UUID = UUID(),
        name: String,
        recipeDescription: String,
        durationMinutes: Int,
        baseServings: Int,
        ingredients: [RecipeIngredient],
        photoData: Data? = nil,
        isBuiltIn: Bool = false,
        isFavorite: Bool = false,
        sourceURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.recipeDescription = recipeDescription
        self.durationMinutes = durationMinutes
        self.baseServings = max(1, baseServings)
        self.ingredients = ingredients
        self.photoData = photoData
        self.isBuiltIn = isBuiltIn
        self.isFavorite = isFavorite
        self.sourceURL = sourceURL
    }

    func updateBaseServings(to servings: Int) {
        baseServings = max(1, servings)
    }
}
