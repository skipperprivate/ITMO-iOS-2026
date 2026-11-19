import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ShoppingViewModel {
    var showsAtHome = false
    var saveFailed = false

    func togglePurchased(_ item: ShoppingItem, in context: ModelContext) {
        item.isPurchased.toggle()
        saveChange(in: context)
    }

    func toggleAtHome(_ item: ShoppingItem, in context: ModelContext) {
        item.isAtHome.toggle()
        item.isPurchased = false
        saveChange(in: context)
    }

    func attach(_ product: VkusVillProduct, to ingredient: Ingredient, in context: ModelContext) throws {
        try ingredient.updateVkusVillProduct(product)
        try save(in: context)
    }

    private func saveChange(in context: ModelContext) {
        do {
            try save(in: context)
        } catch {
            saveFailed = true
        }
    }

    private func save(in context: ModelContext) throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
