import XCTest
@testable import MenuPlanner

@MainActor
final class ShoppingListBuilderTests: XCTestCase {
    private let builder = ShoppingListBuilder()

    func testEmptyPlanProducesEmptyList() throws {
        XCTAssertTrue(try builder.build(from: []).isEmpty)
    }

    func testScalesIngredientsToPlannedServings() throws {
        let ingredient = Ingredient(name: "Рис")
        let entry = meal(ingredient, quantity: 160, unit: .gram, baseServings: 2, servings: 3)
        let item = try XCTUnwrap(builder.build(from: [entry]).first)
        XCTAssertEqual(item.quantity, 240, accuracy: 0.000_001)
        XCTAssertEqual(item.ingredient.id, ingredient.id)
        XCTAssertFalse(item.isPurchased)
        XCTAssertFalse(item.isAtHome)
        XCTAssertEqual(entry.recipe.ingredients[0].quantity, 160, "Calculation must not change the recipe")
    }

    func testMergesSameIngredientAfterNormalizingUnits() throws {
        let rice = Ingredient(name: "Рис")
        let entries = [meal(rice, quantity: 0.5, unit: .kilogram),
                       meal(rice, quantity: 200, unit: .gram)]
        let items = try builder.build(from: entries)
        XCTAssertEqual(items.count, 1)
        let item = try XCTUnwrap(items.first)
        XCTAssertEqual(item.unit, .gram)
        XCTAssertEqual(item.quantity, 700, accuracy: 0.000_001)
    }

    func testKeepsIncompatibleUnitsSeparate() throws {
        let milk = Ingredient(name: "Молоко")
        let items = try builder.build(from: [meal(milk, quantity: 1, unit: .liter),
                                              meal(milk, quantity: 2, unit: .tablespoon)])
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(Set(items.map(\.unit)), [.milliliter, .tablespoon])
    }

    func testDoesNotMergeDifferentIngredientsWithSameName() throws {
        let items = try builder.build(from: [meal(Ingredient(name: "Рис"), quantity: 100, unit: .gram),
                                              meal(Ingredient(name: "Рис"), quantity: 200, unit: .gram)])
        XCTAssertEqual(items.count, 2)
    }

    func testRejectsZeroAndNegativePlannedServings() {
        for servings in [0, -1] {
            let entry = meal(Ingredient(name: "Рис"), quantity: 100, unit: .gram, servings: servings)
            XCTAssertThrowsError(try builder.build(from: [entry])) { error in
                guard case ShoppingListBuilderError.invalidPlannedServings(let name) = error else {
                    return XCTFail("Unexpected error: \(error)")
                }
                XCTAssertEqual(name, "Блюдо")
            }
        }
    }

    func testUnitConverterNormalizesMassAndVolumeAndPreservesOtherUnits() {
        let converter = MenuPlanner.UnitConverter()
        for (unit, quantity, expectedUnit, expectedQuantity): (MeasurementUnit, Double, MeasurementUnit, Double) in [
            (.kilogram, 0.125, .gram, 125), (.liter, 1.5, .milliliter, 1_500),
            (.gram, 12, .gram, 12), (.milliliter, 30, .milliliter, 30),
            (.piece, 2, .piece, 2), (.teaspoon, 0.5, .teaspoon, 0.5),
            (.tablespoon, 3, .tablespoon, 3)
        ] {
            let actual = converter.normalize(quantity: quantity, unit: unit)
            XCTAssertEqual(actual.unit, expectedUnit)
            XCTAssertEqual(actual.quantity, expectedQuantity, accuracy: 0.000_001)
        }
    }

    private func meal(_ ingredient: Ingredient, quantity: Double, unit: MeasurementUnit,
                      baseServings: Int = 1, servings: Int = 1) -> MealPlanEntry {
        let recipe = Recipe(name: "Блюдо", recipeDescription: "", durationMinutes: 15,
                            baseServings: baseServings,
                            ingredients: [RecipeIngredient(ingredient: ingredient, quantity: quantity, unit: unit)])
        return MealPlanEntry(date: .now, mealType: .dinner, recipe: recipe, servings: servings)
    }
}
