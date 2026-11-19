import XCTest
@testable import MenuPlanner

@MainActor
final class RecipeImportMapperTests: XCTestCase {
    func testDurationHandlesMinutesHoursAndUpperBoundOfRange() {
        for (source, expected) in [("30 мин", 30), ("2 часа", 120), ("15–25 минут", 25), ("до 45 мин", 45)] {
            XCTAssertEqual(RecipeImportMapper.duration(from: source), expected, source)
        }
        for source: String? in [nil, "", "неизвестно", "0 мин", "25 часов", "1 час 30 минут"] {
            XCTAssertNil(RecipeImportMapper.duration(from: source))
        }
    }

    func testImportParsesCommaAndFractionAndRetainsUnrecognizedQuantityForReview() throws {
        let recipe = try decodeRecipe(#"""
        {"id":1,"name":"Каша","ingredients":[
          {"name":"Молоко","quantity":"0,5 л","ids":["42","invalid","-1","0"]},
          {"name":"Сахар","quantity":"1/2 ч. л."},
          {"name":"Соль","quantity":"по вкусу"}
        ]}
        """#)
        let rows = RecipeImportMapper.ingredients(from: recipe)
        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(rows[0].parsedQuantity, 0.5)
        XCTAssertEqual(rows[0].unit, .liter)
        XCTAssertEqual(rows[0].suggestedProductIDs, [42])
        XCTAssertNil(rows[0].sourceQuantity)
        XCTAssertEqual(rows[1].parsedQuantity, 0.5)
        XCTAssertEqual(rows[1].unit, .teaspoon)
        XCTAssertEqual(rows[2].sourceQuantity, "по вкусу")
        XCTAssertNotNil(rows[2].quantityError)
    }

    func testInstructionsSortStepsAndKeepDescription() throws {
        let recipe = try decodeRecipe(#"""
        {"id":1,"name":"Каша","description":"На завтрак","steps":[
          {"stepNumber":2,"text":"Подать"},{"stepNumber":1,"text":"Сварить"}
        ]}
        """#)
        XCTAssertEqual(RecipeImportMapper.instructions(from: recipe), "На завтрак\n\n1. Сварить\n2. Подать")
    }

    func testImportedLinksOnlyAcceptOfficialHTTPSHost() throws {
        for url in ["http://vkusvill.ru/recipe", "https://vkusvill.ru.example.com/recipe", "https://example.com/recipe"] {
            let recipe = try decodeRecipe("{\"id\":1,\"name\":\"Каша\",\"url\":\"\(url)\",\"image\":\"\(url)\"}")
            XCTAssertNil(recipe.sourceURL)
            XCTAssertNil(recipe.photoURL)
        }
        let recipe = try decodeRecipe(#"{"id":1,"name":"Каша","url":"https://vkusvill.ru/recipe"}"#)
        XCTAssertEqual(recipe.sourceURL?.absoluteString, "https://vkusvill.ru/recipe")
    }

    func testAllSupportedUnitsAndFractionSeparators() throws {
        let cases: [(String, Double, MeasurementUnit)] = [
            ("100 граммов", 100, .gram), ("1,5 килограмма", 1.5, .kilogram),
            ("250 миллилитров", 250, .milliliter), ("2 литра", 2, .liter),
            ("3 штуки", 3, .piece), ("1⁄2 чайной ложки", 0.5, .teaspoon),
            ("2 столовые ложки", 2, .tablespoon), ("1/4 столовой ложки", 0.25, .tablespoon)
        ]
        for (quantity, amount, unit) in cases {
            let json = try JSONSerialization.data(withJSONObject: ["id": 1, "name": "Рецепт",
                "ingredients": [["name": "Продукт", "quantity": quantity]]])
            let recipe = try JSONDecoder().decode(VkusVillRecipe.self, from: json)
            let row = try XCTUnwrap(RecipeImportMapper.ingredients(from: recipe).first)
            XCTAssertEqual(row.parsedQuantity, amount, quantity)
            XCTAssertEqual(row.unit, unit, quantity)
        }
    }

    func testInvalidZeroAndMissingQuantitiesRemainUnresolved() throws {
        for quantity in ["", "0 г", "1/0 г", "-2 г", "сто граммов", "2 чашки"] {
            let json = try JSONSerialization.data(withJSONObject: ["id": 1, "name": "Рецепт",
                "ingredients": [["name": "Продукт", "quantity": quantity]]])
            let recipe = try JSONDecoder().decode(VkusVillRecipe.self, from: json)
            let row = try XCTUnwrap(RecipeImportMapper.ingredients(from: recipe).first)
            XCTAssertNil(row.parsedQuantity, quantity)
            XCTAssertNotNil(row.sourceQuantity)
        }
        let recipe = try decodeRecipe(#"{"id":1,"name":"Каша","ingredients":[{"name":"Рис"}]}"#)
        XCTAssertEqual(RecipeImportMapper.ingredients(from: recipe).first?.sourceQuantity, "не указано")
        XCTAssertTrue(RecipeImportMapper.ingredients(from: try decodeRecipe(#"{"id":1,"name":"Каша"}"#)).isEmpty)
        XCTAssertEqual(RecipeImportMapper.instructions(from: recipe), "")
    }

    func testDurationBoundaryAndUnsupportedFormats() {
        XCTAssertEqual(RecipeImportMapper.duration(from: "1 мин"), 1)
        XCTAssertEqual(RecipeImportMapper.duration(from: "24 часа"), 1_440)
        XCTAssertEqual(RecipeImportMapper.duration(from: "более 30 мин"), 30)
        for source in ["1441 мин", "-1 мин", "0 часов", "1.5 часа", "30", "тридцать минут"] {
            XCTAssertNil(RecipeImportMapper.duration(from: source), source)
        }
    }

    private func decodeRecipe(_ json: String) throws -> VkusVillRecipe {
        try JSONDecoder().decode(VkusVillRecipe.self, from: Data(json.utf8))
    }
}
