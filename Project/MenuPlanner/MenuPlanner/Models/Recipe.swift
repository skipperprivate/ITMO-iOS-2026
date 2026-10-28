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
    var baseServings: Int
    var photoData: Data?
    
    @Relationship(deleteRule:  .cascade)
    var ingredients: [RecipeIngredient]
    
    init (
        id: UUID = UUID(),
        name: String,
        recipeDescription: String,
        durationMinutes: Int,
        baseServings: Int,
        ingredients: [RecipeIngredient]
    ) {
        self.id = id
        self.name = name
        self.recipeDescription = recipeDescription
        self.durationMinutes = durationMinutes
        self.baseServings = baseServings
        self.ingredients = ingredients
    }
}
