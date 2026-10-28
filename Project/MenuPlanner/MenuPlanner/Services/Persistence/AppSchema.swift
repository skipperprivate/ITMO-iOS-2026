//
//  AppSchema.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import SwiftData

enum AppSchema {
    static let models: [any PersistentModel.Type] = [
        Recipe.self,
        MealPlanEntry.self,
        ShoppingList.self
    ]
}
