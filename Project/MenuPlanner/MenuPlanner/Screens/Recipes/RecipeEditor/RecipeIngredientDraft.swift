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

    init(name: String = "", quantity: String = "", unit: MeasurementUnit = .gram) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
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
