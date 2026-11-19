//
//  MealPlanEntry.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import  SwiftData
import Foundation

@Model
final class MealPlanEntry {
    private(set) var id: UUID
    var date: Date
    var mealType: MealType
    var recipe: Recipe
    var servings: Int
    
    init (
        id: UUID = UUID(),
        date: Date,
        mealType: MealType,
        recipe: Recipe,
        servings: Int
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.recipe = recipe
        self.servings = servings
    }
}
