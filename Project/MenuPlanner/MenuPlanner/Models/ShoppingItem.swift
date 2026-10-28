//
//  ShoppingItem.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import SwiftData
import Foundation

@Model
final class ShoppingItem {
    private(set) var id: UUID
    var ingredient: Ingredient
    var quantity: Double
    var unit: MeasurementUnit
    var isPurchased: Bool = false
    var isAtHome: Bool = false
    
    init (
        id: UUID = UUID(),
        ingredient: Ingredient,
        quantity: Double,
        unit: MeasurementUnit,
        isPurchased: Bool,
        isAtHome: Bool
    ) {
        self.id = id
        self.ingredient = ingredient
        self.quantity = quantity
        self.unit = unit
        self.isPurchased = isPurchased
        self.isAtHome = isAtHome
    }
}
