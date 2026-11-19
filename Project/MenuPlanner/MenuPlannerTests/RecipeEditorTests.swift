import SwiftData
import XCTest
@testable import MenuPlanner

@MainActor
final class RecipeEditorTests: XCTestCase {
    func testInvalidSaveShowsValidationWithoutInsertingRecipe() throws {
        let container = try makeContainer()
        let viewModel = RecipeEditorViewModel()
        XCTAssertFalse(viewModel.canSave)
        XCTAssertNil(viewModel.validationMessage(for: .name))
        XCTAssertThrowsError(try viewModel.save(in: container.mainContext)) { error in
            guard case RecipeValidationError.nameRequired = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
        XCTAssertTrue(viewModel.hasAttemptedSave)
        XCTAssertEqual(viewModel.firstInvalidField, .name)
        XCTAssertNotNil(viewModel.validationMessage(for: .name))
        XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<Recipe>()), 0)
    }

    func testParameterValidationRejectsValuesOutsideAllowedRanges() {
        let viewModel = validEditor()
        for duration in [0, 1_441] {
            viewModel.durationMinutes = duration
            XCTAssertEqual(viewModel.firstInvalidField, .duration)
            XCTAssertThrowsError(try viewModel.validate())
        }
        viewModel.durationMinutes = 1_440
        for servings in [0, 101] {
            viewModel.baseServings = servings
            XCTAssertEqual(viewModel.firstInvalidField, .servings)
        }
        viewModel.baseServings = 100
        XCTAssertTrue(viewModel.canSave)
    }

    func testRemovingLastIngredientRequiresAnotherIngredient() {
        let viewModel = validEditor()
        viewModel.removeIngredient(id: viewModel.ingredients[0].id)
        XCTAssertEqual(viewModel.firstInvalidField, .ingredients)
        XCTAssertThrowsError(try viewModel.validate())
    }

    func testQuantityAcceptsDecimalCommaAndRejectsInvalidNumbers() {
        let row = RecipeIngredientDraft(name: "Рис", quantity: " 1,25 ")
        XCTAssertEqual(row.parsedQuantity, 1.25)
        XCTAssertNil(row.quantityError)
        for invalid in ["", "0", "-1", "abc", "nan", "inf", "1e309"] {
            row.quantity = invalid
            XCTAssertNotNil(row.quantityError, "Must reject \(invalid)")
        }
    }

    func testRenamingImportedIngredientClearsProductSuggestions() {
        let row = RecipeIngredientDraft(name: "Молоко", quantity: "1", suggestedProductIDs: [42])
        row.name = "  МОЛОКО  "
        XCTAssertEqual(row.suggestedProductIDs, [42])
        row.name = "Рис"
        XCTAssertTrue(row.suggestedProductIDs.isEmpty)
    }

    func testPhotoLoadingPreventsSaveAvailability() {
        let viewModel = validEditor()
        XCTAssertTrue(viewModel.canSave)
        viewModel.isLoadingPhoto = true
        XCTAssertFalse(viewModel.canSave)
    }

    func testSaveTrimsTextAndReusesIngredientAcrossRecipes() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let existing = Ingredient(name: "Рис")
        context.insert(existing)
        try context.save()
        let viewModel = validEditor()
        viewModel.name = "  Рисовая каша \n"
        viewModel.instructions = "  Сварить рис.  "
        viewModel.ingredients[0].name = "  РИС "
        viewModel.ingredients[0].quantity = "1,5"
        let saved = try viewModel.save(in: context)
        // Fetch in a fresh context to verify persistence rather than just object mutation.
        let reader = ModelContext(container)
        let stored = try XCTUnwrap(reader.fetch(FetchDescriptor<Recipe>()).first)
        XCTAssertEqual(stored.id, saved.id)
        XCTAssertEqual(stored.name, "Рисовая каша")
        XCTAssertEqual(stored.recipeDescription, "Сварить рис.")
        XCTAssertEqual(stored.ingredients[0].ingredient.id, existing.id)
        XCTAssertEqual(stored.ingredients[0].quantity, 1.5)
        XCTAssertEqual(try reader.fetchCount(FetchDescriptor<Ingredient>()), 1)
    }

    func testEditingReplacesRowsWithoutDuplicatingRecipeOrDeletingSharedIngredient() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let saved = try validEditor().save(in: context)
        let originalID = saved.id
        let oldRowID = saved.ingredients[0].id
        let ingredientID = saved.ingredients[0].ingredient.id
        let editor = RecipeEditorViewModel(recipe: saved)
        editor.name = "Обновлённый рецепт"
        editor.ingredients[0].quantity = "250"
        editor.baseServings = 4
        try editor.save(in: context)
        let reader = ModelContext(container)
        let recipes = try reader.fetch(FetchDescriptor<Recipe>())
        XCTAssertEqual(recipes.count, 1)
        let updated = try XCTUnwrap(recipes.first)
        XCTAssertEqual(updated.id, originalID)
        XCTAssertEqual(updated.name, "Обновлённый рецепт")
        XCTAssertEqual(updated.baseServings, 4)
        XCTAssertEqual(updated.ingredients[0].quantity, 250)
        XCTAssertEqual(updated.ingredients[0].ingredient.id, ingredientID)
        XCTAssertFalse(try reader.fetch(FetchDescriptor<RecipeIngredient>()).contains { $0.id == oldRowID })
    }

    private func validEditor() -> RecipeEditorViewModel {
        let editor = RecipeEditorViewModel()
        editor.name = "Каша"
        editor.ingredients = [RecipeIngredientDraft(name: "Рис", quantity: "100", unit: .gram)]
        return editor
    }

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(for: Schema(AppSchema.models),
                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
}
