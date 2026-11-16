//
//  Ingredient.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import SwiftData
import Foundation

@Model
final class Ingredient {
    private(set) var id : UUID
    var name: String
    var category: IngredientCategory
    private var storeURL: URL?

    init (
        id: UUID = UUID(),
        name: String,
        category: IngredientCategory = .other,
        storeURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.storeURL = storeURL
    }

    func updateUrl(with url: URL?) {
        self.storeURL = url
    }
}
