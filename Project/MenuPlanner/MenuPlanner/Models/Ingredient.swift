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
    private(set) var storeURL: URL?
    private var vkusVillProductData: Data?
    private(set) var suggestedVkusVillProductIDs: [Int]?

    var vkusVillProduct: VkusVillProduct? {
        guard let vkusVillProductData else { return nil }
        return try? JSONDecoder().decode(VkusVillProduct.self, from: vkusVillProductData)
    }

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

    func updateVkusVillProduct(_ product: VkusVillProduct) throws {
        vkusVillProductData = try JSONEncoder().encode(product)
    }

    func addVkusVillProductSuggestions(_ ids: [Int]) {
        guard !ids.isEmpty else { return }
        var existing = suggestedVkusVillProductIDs ?? []
        for id in ids where !existing.contains(id) {
            existing.append(id)
        }
        suggestedVkusVillProductIDs = existing
    }
}
