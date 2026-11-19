import Foundation
import Observation

@MainActor
@Observable
final class VkusVillCartViewModel {
    struct Line: Identifiable {
        let ingredient: Ingredient
        let items: [ShoppingItem]
        var id: UUID { ingredient.id }

        var requiredAmount: String {
            items.map { RecipeFormatting.quantity($0.quantity, unit: $0.unit) }.joined(separator: " + ")
        }
    }

    let lines: [Line]
    private(set) var quantities: [UUID: String] = [:]
    private(set) var skipped: Set<UUID> = []
    private(set) var editingID: UUID?
    private(set) var cartURL: URL?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let catalog = VkusVillCatalog()

    init(items: [ShoppingItem]) {
        let pending = items.filter { !$0.isAtHome && !$0.isPurchased }
        lines = Dictionary(grouping: pending, by: { $0.ingredient.id }).values.compactMap { group in
            guard let ingredient = group.first?.ingredient else { return nil }
            return Line(ingredient: ingredient, items: group)
        }.sorted { lhs, rhs in
            lhs.ingredient.name.localizedStandardCompare(rhs.ingredient.name) == .orderedAscending
        }
        for line in lines {
            if let product = line.ingredient.vkusVillProduct {
                quantities[line.id] = suggestedAmount(for: line, product: product)
            }
        }
    }

    var currentLine: Line? {
        if let editingID, let line = lines.first(where: { $0.id == editingID }) {
            return line
        }
        return pendingLines.first
    }

    var pendingLines: [Line] {
        lines.filter { !skipped.contains($0.id) && $0.ingredient.vkusVillProduct == nil }
    }

    func setQuantity(_ value: String, for id: UUID) {
        quantities[id] = value
        cartURL = nil
        errorMessage = nil
    }

    func changeProduct(for line: Line) {
        editingID = line.id
    }

    func use(_ product: VkusVillProduct, for line: Line) {
        setQuantity(suggestedAmount(for: line, product: product), for: line.id)
        skipped.remove(line.id)
        editingID = nil
    }

    func skip(_ line: Line) {
        if line.ingredient.vkusVillProduct == nil {
            skipped.insert(line.id)
        }
        editingID = nil
    }

    func revisitSkipped() {
        skipped.removeAll()
        cartURL = nil
        errorMessage = nil
    }

    func buildCart() async {
        guard !isLoading, currentLine == nil, !Task.isCancelled else { return }
        errorMessage = nil
        cartURL = nil
        guard let items = cartItems() else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let link = try await catalog.createCartLink(items: items)
            try Task.checkCancellation()
            cartURL = link
        } catch {
            if !Task.isCancelled {
                errorMessage = "Не удалось получить ссылку на корзину. Попробуй ещё раз."
            }
        }
    }

    private func cartItems() -> [VkusVillCatalog.CartItem]? {
        var amounts: [Int: Double] = [:]
        for line in lines where !skipped.contains(line.id) {
            guard let product = line.ingredient.vkusVillProduct else { continue }
            let text = quantities[line.id, default: ""].trimmingCharacters(in: .whitespacesAndNewlines)
            guard let quantity = Double(text.replacingOccurrences(of: ",", with: ".")),
                  (0.01...40).contains(quantity), (product.cartUnit == "кг" || quantity.rounded() == quantity) else {
                errorMessage = "Укажи корректное количество для «\(line.ingredient.name)»."
                return nil
            }
            amounts[product.id, default: 0] += quantity
        }
        guard !amounts.isEmpty else {
            errorMessage = "Выбери хотя бы один товар."
            return nil
        }
        guard amounts.count <= 100, amounts.values.allSatisfy({ $0 <= 40 }) else {
            errorMessage = "В одну корзину можно добавить до 100 товаров и до 40 единиц каждого товара."
            return nil
        }
        return amounts.sorted(by: { $0.key < $1.key }).map {
            VkusVillCatalog.CartItem(id: $0.key, q: $0.value)
        }
    }

    private func suggestedAmount(for line: Line, product: VkusVillProduct) -> String {
        product.suggestedQuantity(for: line.items)?.formatted(.number.grouping(.never)) ?? ""
    }
}
