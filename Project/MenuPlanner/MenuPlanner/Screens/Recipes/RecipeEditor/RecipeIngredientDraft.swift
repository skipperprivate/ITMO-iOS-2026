//
//  RecipeIngredientDraft.swift
//  MenuPlanner
//
//  Created by FergeS on 16/11/2026.
//
import Foundation

@MainActor
@Observable
final class RecipeIngredientDraft: Identifiable {
    let id = UUID()
    var name: String
    var quantity: String
    var unit: MeasurementUnit
    let sourceQuantity: String?
    private let importedName: String
    private let importedProductIDs: [Int]

    init(name: String = "",
         quantity: String = "",
         unit: MeasurementUnit = .gram,
         sourceQuantity: String? = nil,
         suggestedProductIDs: [Int] = []
    ) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        
        self.sourceQuantity = sourceQuantity
        self.importedName = name
        self.importedProductIDs = suggestedProductIDs
    }

    var suggestedProductIDs: [Int] {
        let currentName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return currentName.caseInsensitiveCompare(importedName.trimmingCharacters(in: .whitespacesAndNewlines))
            == .orderedSame ? importedProductIDs : []
    }

    var nameError: String? {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Укажи название продукта" : nil
    }

    var parsedQuantity: Double? {
        Double(quantity.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "."))
    }

    var quantityError: String? {
        guard let value = parsedQuantity, value.isFinite, value > 0 else {
            return "Укажи количество больше нуля"
        }
        return nil
    }
}
