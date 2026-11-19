//
//  ShoppingListBuilder.swift
//  MenuPlanner
//
//  Created by FergeS on 31/10/2026.
//
import Foundation

struct ShoppingListBuilder {
    private let unitConverter = UnitConverter()
    
    func build(from entries: [MealPlanEntry]) throws -> [ShoppingItem] {
        var result = [ShoppingItem]()
        
        for entry in entries {
            guard entry.servings > 0 else {
                throw ShoppingListBuilderError.invalidPlannedServings(recipeName: entry.recipe.name)
            }
            
            let multiplier: Double = Double(entry.servings) / Double(entry.recipe.baseServings)
            
            for recipeIngredient in entry.recipe.ingredients {
                let newQuantity = recipeIngredient.quantity * multiplier
                
                let normalized = unitConverter.normalize(quantity: newQuantity, unit: recipeIngredient.unit)
                
                let item = ShoppingItem(ingredient: recipeIngredient.ingredient ,
                                                    quantity: normalized.quantity,
                                                    unit: normalized.unit)
                
                if let existingItem = result.first(where: {item in
                    item.ingredient.id == recipeIngredient.ingredient.id &&
                    item.unit == normalized.unit
                }) {
                    existingItem.quantity += item.quantity
                } else {
                    result.append(item)
                }
            }
        }
        
        return result
    }
}


enum ShoppingListBuilderError: LocalizedError {
    case invalidPlannedServings(recipeName: String)
    
    var errorDescription: String? {
        switch self {
            case .invalidPlannedServings(let recipeName):
                return "Для блюда «\(recipeName)» в меню нужно указать хотя бы одну порцию."
        }
    }
}
