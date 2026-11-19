//
//  RecipeIngredient.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import SwiftData
import Foundation

@Model
final class RecipeIngredient {
    private(set) var id: UUID
    var ingredient: Ingredient
    var quantity: Double
    var unit: MeasurementUnit
    
    init (
        id: UUID = UUID(),
        ingredient: Ingredient,
        quantity: Double,
        unit: MeasurementUnit = .piece
    ) {
        self.id = id
        self.ingredient = ingredient
        self.quantity = quantity
        self.unit = unit
    }
}
