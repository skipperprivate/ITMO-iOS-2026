import XCTest
@testable import MenuPlanner

@MainActor
final class VkusVillProductTests: XCTestCase {
    func testWeightedProductsSumMassAndRoundUpToHundredthKilogram() {
        let product = product(unit: "КГ")
        XCTAssertEqual(product.cartUnit, "кг")
        XCTAssertEqual(product.suggestedQuantity(for: [item(0.3, .kilogram), item(205, .gram)]), 0.51)
        XCTAssertEqual(product.suggestedQuantity(for: [item(300, .gram)]), 0.3, "No extra rounding from floating-point noise")
    }

    func testPackagedMassRoundsUpToWholePacks() {
        for weight in [VkusVillProduct.Weight(value: 500, unit: "г"), .init(value: 0.5, unit: "кг")] {
            let product = product(weight: weight)
            XCTAssertEqual(product.suggestedQuantity(for: [item(0.6, .kilogram)]), 2)
            XCTAssertEqual(product.suggestedQuantity(for: [item(500, .gram)]), 1)
            XCTAssertEqual(product.suggestedQuantity(for: [item(100, .gram), item(100, .gram)]), 1)
        }
    }

    func testPackagedVolumeParsesLitersMillilitersAndDecimalComma() {
        for name in ["Молоко 0,5 л", "Молоко 0.5 л.", "Молоко 500 мл"] {
            XCTAssertEqual(product(name: name).suggestedQuantity(for: [item(0.6, .liter)]), 2, name)
            XCTAssertEqual(product(name: name).suggestedQuantity(for: [item(500, .milliliter)]), 1, name)
        }
    }

    func testPiecesRequirePieceUnitAndRoundUp() {
        for unit in ["шт", "шт."] {
            XCTAssertEqual(product(unit: unit).suggestedQuantity(for: [item(2.2, .piece)]), 3)
        }
        XCTAssertNil(product(unit: "уп").suggestedQuantity(for: [item(1, .piece)]))
    }

    func testMissingInvalidOrUnsupportedPackageWeightNeedsManualQuantity() {
        for weight: VkusVillProduct.Weight? in [nil, .init(value: 0, unit: "г"), .init(value: -1, unit: "г"),
                                                .init(value: .infinity, unit: "г"), .init(value: .nan, unit: "г"),
                                                .init(value: 1, unit: "фунт")] {
            XCTAssertNil(product(weight: weight).suggestedQuantity(for: [item(100, .gram)]))
        }
    }

    func testInvalidOrUnknownVolumeNeedsManualQuantity() {
        for name in ["Молоко", "Молоко 0 л", "Молоко 500 г", "Молоко 1 л (бутылка)"] {
            XCTAssertNil(product(name: name).suggestedQuantity(for: [item(100, .milliliter)]), name)
        }
    }

    func testIncompatibleUnitsDoNotProduceAnAutomaticSuggestion() {
        for unit in [MeasurementUnit.teaspoon, .tablespoon] {
            XCTAssertNil(product().suggestedQuantity(for: [item(1, unit)]))
        }
        XCTAssertNil(product(unit: "кг").suggestedQuantity(for: [item(1, .piece)]))
        XCTAssertNil(product(unit: "кг").suggestedQuantity(for: [item(100, .milliliter)]))
        XCTAssertNil(product().suggestedQuantity(for: [item(100, .gram), item(1, .teaspoon)]))
    }

    func testQuantityLimitsIncludeFortyAndRejectEmptyZeroAndOverLimit() {
        let weight = product(unit: "кг")
        XCTAssertEqual(weight.suggestedQuantity(for: [item(0.01, .kilogram)]), 0.01)
        XCTAssertEqual(weight.suggestedQuantity(for: [item(40, .kilogram)]), 40)
        XCTAssertNil(weight.suggestedQuantity(for: [item(40.001, .kilogram)]))
        XCTAssertNil(weight.suggestedQuantity(for: []))
        XCTAssertNil(weight.suggestedQuantity(for: [item(0, .gram)]))
        XCTAssertNil(product().suggestedQuantity(for: [item(41, .piece)]))
    }

    func testDisplayNameDecodesEntitiesAndOptionalMetadataIsSafe() {
        let product = VkusVillProduct(id: 1, name: "Рис&nbsp;&quot;А&amp;Б&quot;", price: .init(current: 99.5),
                                      unit: nil, weight: nil, url: URL(string: "https://vkusvill.ru/item"),
                                      images: [.init(small: URL(string: "https://vkusvill.ru/photo"))])
        XCTAssertEqual(product.displayName, "Рис \"А&Б\"")
        XCTAssertNotNil(product.priceText)
        XCTAssertEqual(product.photoURL?.path, "/photo")
        XCTAssertEqual(product.pageURL?.path, "/item")
        XCTAssertEqual(product.cartUnit, "шт.")
        let empty = self.product()
        XCTAssertNil(empty.priceText)
        XCTAssertNil(empty.photoURL)
        XCTAssertNil(empty.pageURL)
    }

    func testProductLinksRejectHostImpersonationAndHTTP() {
        for url in ["http://vkusvill.ru/item", "https://example.com/item", "https://vkusvill.ru.example.com/item"] {
            let product = VkusVillProduct(id: 1, name: "Рис", price: nil, unit: nil, weight: nil,
                                          url: URL(string: url), images: nil)
            XCTAssertNil(product.pageURL)
        }
    }

    func testIngredientPersistsProductAndDeduplicatesSuggestions() throws {
        let ingredient = Ingredient(name: "Рис")
        ingredient.addVkusVillProductSuggestions([])
        XCTAssertNil(ingredient.suggestedVkusVillProductIDs)
        ingredient.addVkusVillProductSuggestions([1, 2, 1])
        ingredient.addVkusVillProductSuggestions([2, 3])
        XCTAssertEqual(ingredient.suggestedVkusVillProductIDs, [1, 2, 3])
        try ingredient.updateVkusVillProduct(product())
        XCTAssertEqual(ingredient.vkusVillProduct?.id, 1)
        ingredient.updateUrl(with: URL(string: "https://vkusvill.ru/item"))
        XCTAssertEqual(ingredient.storeURL?.path, "/item")
        ingredient.updateUrl(with: nil)
        XCTAssertNil(ingredient.storeURL)
    }

    private func product(name: String = "Рис", unit: String = "шт",
                         weight: VkusVillProduct.Weight? = .init(value: 500, unit: "г")) -> VkusVillProduct {
        VkusVillProduct(id: 1, name: name, price: nil, unit: unit, weight: weight, url: nil, images: nil)
    }

    private func item(_ quantity: Double, _ unit: MeasurementUnit) -> ShoppingItem {
        ShoppingItem(ingredient: Ingredient(name: "Продукт"), quantity: quantity, unit: unit)
    }
}
