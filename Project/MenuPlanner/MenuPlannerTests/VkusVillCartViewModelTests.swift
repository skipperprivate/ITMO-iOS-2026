import XCTest
@testable import MenuPlanner

@MainActor
final class VkusVillCartViewModelTests: CatalogTestCase {
    func testGroupsByIngredientSortsAndExcludesPurchasedAndAtHomeItems() throws {
        let first = Ingredient(name: "А")
        let second = Ingredient(name: "Б")
        let purchased = item(Ingredient(name: "Куплен"))
        purchased.isPurchased = true
        let atHome = item(Ingredient(name: "Дома"))
        atHome.isAtHome = true
        let model = VkusVillCartViewModel(
            items: [item(second), item(first), item(first), purchased, atHome], catalog: catalog
        )
        XCTAssertEqual(model.lines.map { $0.ingredient.name }, ["А", "Б"])
        XCTAssertEqual(model.lines[0].items.count, 2)
        XCTAssertEqual(model.currentLine?.id, first.id)
        XCTAssertEqual(model.pendingLines.count, 2)
        XCTAssertTrue(model.lines[0].requiredAmount.contains(" + "))
    }

    func testSkipRevisitAndEditingOrder() throws {
        let first = Ingredient(name: "А")
        let second = Ingredient(name: "Б")
        let model = VkusVillCartViewModel(items: [item(first), item(second)], catalog: catalog)
        let firstLine = try XCTUnwrap(model.currentLine)
        model.skip(firstLine)
        XCTAssertEqual(model.skipped, [first.id])
        XCTAssertEqual(model.currentLine?.id, second.id)
        model.changeProduct(for: firstLine)
        XCTAssertEqual(model.currentLine?.id, first.id)
        model.skip(firstLine)
        model.revisitSkipped()
        XCTAssertTrue(model.skipped.isEmpty)
        XCTAssertNil(model.editingID)
        XCTAssertEqual(model.currentLine?.id, first.id)
    }

    func testChoosingProductClearsSkippedAndResetsEditingWithSuggestedAmount() throws {
        let ingredient = Ingredient(name: "Рис")
        let model = VkusVillCartViewModel(items: [item(ingredient, quantity: 600)], catalog: catalog)
        let line = try XCTUnwrap(model.currentLine)
        model.skip(line)
        model.changeProduct(for: line)
        let selected = product()
        try ingredient.updateVkusVillProduct(selected)
        model.use(selected, for: line)
        XCTAssertTrue(model.skipped.isEmpty)
        XCTAssertNil(model.editingID)
        XCTAssertNil(model.currentLine)
        XCTAssertEqual(model.quantities[line.id], "2")
        model.changeProduct(for: line)
        model.skip(line)
        XCTAssertTrue(model.skipped.isEmpty, "Keeping a selected product must not exclude it")
    }

    func testUnresolvedProductsPreventBuildingWithoutSendingRequest() async {
        let model = VkusVillCartViewModel(items: [item(Ingredient(name: "Рис"))], catalog: catalog)
        await model.buildCart()
        XCTAssertNil(model.cartURL)
        XCTAssertNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testEmptyAndAllSkippedCartsShowValidationWithoutHTTP() async throws {
        let empty = VkusVillCartViewModel(items: [], catalog: catalog)
        await empty.buildCart()
        XCTAssertEqual(empty.errorMessage, "Выбери хотя бы один товар.")
        let model = VkusVillCartViewModel(items: [item(Ingredient(name: "Рис"))], catalog: catalog)
        model.skip(try XCTUnwrap(model.currentLine))
        await model.buildCart()
        XCTAssertEqual(model.errorMessage, "Выбери хотя бы один товар.")
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testPackagedProductsRejectFractionalNonFiniteAndOutOfRangeQuantities() async throws {
        let ingredient = Ingredient(name: "Рис")
        try ingredient.updateVkusVillProduct(product())
        let model = VkusVillCartViewModel(items: [item(ingredient)], catalog: catalog)
        for value in ["", "0", "-1", "0.5", "41", "nan", "inf", "abc"] {
            model.setQuantity(value, for: ingredient.id)
            await model.buildCart()
            XCTAssertNotNil(model.errorMessage, value)
            XCTAssertFalse(model.isLoading)
            XCTAssertNil(model.cartURL)
        }
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testWeightedQuantitiesAcceptCommaAndMergedProductIDsAreSummed() async throws {
        let first = Ingredient(name: "А")
        let second = Ingredient(name: "Б")
        let selected = product(42, unit: "кг")
        try first.updateVkusVillProduct(selected)
        try second.updateVkusVillProduct(selected)
        let model = VkusVillCartViewModel(items: [item(first), item(second)], catalog: catalog)
        model.setQuantity(" 0,25 ", for: first.id)
        model.setQuantity("0.5", for: second.id)
        serveTool(["link": "https://vkusvill.ru/cart/test"])
        await model.buildCart()
        XCTAssertEqual(model.cartURL?.path, "/cart/test")
        XCTAssertNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
        let body = try Self.body(of: XCTUnwrap(StubURLProtocol.requests.last))
        let args = (body["params"] as? [String: Any])?["arguments"] as? [String: Any]
        let products = try XCTUnwrap(args?["products"] as? [[String: Any]])
        XCTAssertEqual(products.count, 1)
        XCTAssertEqual(products[0]["id"] as? Int, 42)
        XCTAssertEqual(products[0]["q"] as? Double, 0.75)
        model.setQuantity("1", for: first.id)
        XCTAssertNil(model.cartURL, "Changing a quantity invalidates the previously generated link")
    }

    func testMergedQuantityOverFortyIsRejectedEvenIfEachLineIsValid() async throws {
        let first = Ingredient(name: "А")
        let second = Ingredient(name: "Б")
        try first.updateVkusVillProduct(product(42))
        try second.updateVkusVillProduct(product(42))
        let model = VkusVillCartViewModel(items: [item(first), item(second)], catalog: catalog)
        model.setQuantity("21", for: first.id)
        model.setQuantity("20", for: second.id)
        await model.buildCart()
        XCTAssertTrue(model.errorMessage?.contains("до 40") == true)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testMoreThanOneHundredDistinctProductsAreRejected() async throws {
        let items = try (1...101).map { id -> ShoppingItem in
            let ingredient = Ingredient(name: "Продукт \(id)")
            try ingredient.updateVkusVillProduct(product(id))
            return item(ingredient)
        }
        let model = VkusVillCartViewModel(items: items, catalog: catalog)
        await model.buildCart()
        XCTAssertTrue(model.errorMessage?.contains("до 100") == true)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testFailedBuildCanBeRetriedAndRevisitClearsLink() async throws {
        let ingredient = Ingredient(name: "Рис")
        try ingredient.updateVkusVillProduct(product())
        let model = VkusVillCartViewModel(items: [item(ingredient)], catalog: catalog)
        await model.buildCart()
        XCTAssertNotNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
        serveTool(["link": "https://vkusvill.ru/cart/test"])
        await model.buildCart()
        XCTAssertNotNil(model.cartURL)
        XCTAssertNil(model.errorMessage)
        model.revisitSkipped()
        XCTAssertNil(model.cartURL)
        XCTAssertNil(model.errorMessage)
    }

    func testCancelledBuildDoesNotStartHTTPOrShowError() async throws {
        let ingredient = Ingredient(name: "Рис")
        try ingredient.updateVkusVillProduct(product())
        let model = VkusVillCartViewModel(items: [item(ingredient)], catalog: catalog)
        let task = Task { await model.buildCart() }
        task.cancel()
        await task.value
        XCTAssertNil(model.cartURL)
        XCTAssertNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testInFlightBuildBlocksDuplicateSubmissionAndCancellationClearsLoading() async throws {
        let ingredient = Ingredient(name: "Рис")
        try ingredient.updateVkusVillProduct(product())
        let started = expectation(description: "Cart request started")
        StubURLProtocol.configure { _ in
            started.fulfill()
            return .init(data: Data(#"{"result":{"protocolVersion":"2025-06-18"}}"#.utf8), delay: 1)
        }
        let model = VkusVillCartViewModel(items: [item(ingredient)], catalog: catalog)
        let task = Task { await model.buildCart() }
        await fulfillment(of: [started], timeout: 3)
        XCTAssertTrue(model.isLoading)
        await model.buildCart()
        XCTAssertEqual(StubURLProtocol.requests.count, 1)
        task.cancel()
        await task.value
        XCTAssertFalse(model.isLoading)
        XCTAssertNil(model.cartURL)
        XCTAssertNil(model.errorMessage)
    }

    private func item(_ ingredient: Ingredient, quantity: Double = 100) -> ShoppingItem {
        ShoppingItem(ingredient: ingredient, quantity: quantity, unit: .gram)
    }
}
