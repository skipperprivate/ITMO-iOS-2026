import SwiftData
import XCTest
@testable import MenuPlanner

@MainActor
final class RecipeEditorAdvancedTests: CatalogTestCase {
    func testValidationPrioritizesNameThenParametersThenIngredientRows() throws {
        let model = RecipeEditorViewModel()
        model.name = " \n "
        XCTAssertEqual(model.firstInvalidField, .name)
        model.name = "Каша"
        model.durationMinutes = 0
        model.baseServings = 0
        XCTAssertEqual(model.firstInvalidField, .duration)
        model.durationMinutes = 15
        XCTAssertEqual(model.firstInvalidField, .servings)
        model.baseServings = 2
        let row = try XCTUnwrap(model.ingredients.first)
        XCTAssertEqual(model.firstInvalidField, .ingredientName(row.id))
        XCTAssertNotNil(model.validationErrors[.ingredientName(row.id)])
        XCTAssertNotNil(model.validationErrors[.ingredientQuantity(row.id)])
        row.name = "Рис"
        XCTAssertEqual(model.firstInvalidField, .ingredientQuantity(row.id))
        XCTAssertThrowsError(try model.validate()) { error in
            guard case RecipeValidationError.invalidIngredient = error else { return XCTFail("Wrong validation error") }
        }
        row.quantity = "100"
        XCTAssertNil(model.firstInvalidField)
        XCTAssertTrue(model.validationErrors.isEmpty)
        XCTAssertNil(model.validationMessage(for: .instructions))
        XCTAssertNoThrow(try model.validate())
    }

    func testValidRangeLowerBoundsAndUnknownRowIDs() {
        let model = RecipeEditorViewModel()
        model.name = "Каша"
        model.durationMinutes = 1
        model.baseServings = 1
        model.ingredients = [RecipeIngredientDraft(name: "Рис", quantity: "0.001")]
        XCTAssertTrue(model.canSave)
        let rowID = model.ingredients[0].id
        model.removeIngredient(id: UUID())
        XCTAssertEqual(model.ingredients.map(\.id), [rowID])
        model.hasAttemptedSave = true
        XCTAssertNil(model.validationMessage(for: .ingredientName(UUID())))
        XCTAssertNil(model.validationMessage(for: .ingredientQuantity(UUID())))
    }

    func testImportFillsEditorAndFallsBackForInvalidPortionsAndTime() throws {
        let valid = try importedRecipe(#"""
        {"id":1,"name":"Каша","portions":4,"cookingTime":{"name":"2 часа"},
         "description":"Завтрак","ingredients":[{"name":"Рис","quantity":"200 г"}]}
        """#)
        let model = RecipeEditorViewModel(importedRecipe: valid)
        XCTAssertEqual(model.name, "Каша")
        XCTAssertEqual(model.baseServings, 4)
        XCTAssertEqual(model.durationMinutes, 120)
        XCTAssertEqual(model.ingredients.first?.parsedQuantity, 200)
        XCTAssertEqual(model.instructions, "Завтрак")
        for portions in [0, -1, 101] {
            let recipe = try importedRecipe("{\"id\":1,\"name\":\"Каша\",\"portions\":\(portions),\"cookingTime\":{\"name\":\"неизвестно\"}}")
            let editor = RecipeEditorViewModel(importedRecipe: recipe)
            XCTAssertEqual(editor.baseServings, 2)
            XCTAssertEqual(editor.durationMinutes, 15)
            XCTAssertEqual(editor.ingredients.count, 1)
            XCTAssertFalse(editor.canSave)
        }
    }

    func testImportedSavePersistsSourcePhotoAndSuggestionsAndReusesDuplicateIngredientRows() throws {
        let recipe = try importedRecipe(#"""
        {"id":1,"name":"Каша","url":"https://vkusvill.ru/recipe","ingredients":[
         {"name":"Рис","quantity":"100 г","ids":["42","43"]},
         {"name":" рис ","quantity":"1 ст. л.","ids":["43","44"]}]}
        """#)
        let model = RecipeEditorViewModel(importedRecipe: recipe)
        model.photoData = Data([1, 2, 3])
        let container = try makeContainer()
        let saved = try model.save(in: container.mainContext)
        XCTAssertEqual(saved.sourceURL?.absoluteString, "https://vkusvill.ru/recipe")
        XCTAssertEqual(saved.photoData, Data([1, 2, 3]))
        XCTAssertEqual(saved.ingredients[0].ingredient.id, saved.ingredients[1].ingredient.id)
        XCTAssertEqual(saved.ingredients[0].ingredient.suggestedVkusVillProductIDs, [42, 43, 44])
        XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<Ingredient>()), 1)
    }

    func testInvalidEditDoesNotMutatePersistedRecipe() throws {
        let container = try makeContainer()
        let recipe = Recipe(name: "Каша", recipeDescription: "Шаги", durationMinutes: 15, baseServings: 2,
                            ingredients: [RecipeIngredient(ingredient: Ingredient(name: "Рис"), quantity: 100)])
        container.mainContext.insert(recipe)
        try container.mainContext.save()
        let editor = RecipeEditorViewModel(recipe: recipe)
        editor.name = "Изменённое название"
        editor.ingredients[0].quantity = "nan"
        XCTAssertThrowsError(try editor.save(in: container.mainContext))
        let reader = ModelContext(container)
        let stored = try XCTUnwrap(reader.fetch(FetchDescriptor<Recipe>()).first)
        XCTAssertEqual(stored.name, "Каша")
        XCTAssertEqual(stored.ingredients[0].quantity, 100)
        XCTAssertEqual(stored.recipeDescription, "Шаги")
    }

    func testPhotoSuccessFailureRetryAndExistingPhotoGuard() async throws {
        let recipe = try importedRecipe(#"{"id":1,"name":"Каша","image":"https://vkusvill.ru/photo"}"#)
        let model = RecipeEditorViewModel(importedRecipe: recipe, catalog: catalog)
        await model.loadImportedPhoto()
        XCTAssertTrue(model.remotePhotoFailed)
        XCTAssertNil(model.photoData)
        XCTAssertFalse(model.isLoadingPhoto)
        StubURLProtocol.configure { _ in .init(headers: ["Content-Type": "image/png"], data: Data([1, 2, 3])) }
        await model.loadImportedPhoto()
        XCTAssertEqual(model.photoData, Data([1, 2, 3]))
        XCTAssertFalse(model.isLoadingPhoto)
        let requestCount = StubURLProtocol.requests.count
        await model.loadImportedPhoto()
        XCTAssertEqual(StubURLProtocol.requests.count, requestCount)
    }

    func testPhotoDoesNotLoadWithoutOfficialURLOrWhileAlreadyLoading() async throws {
        for json in [#"{"id":1,"name":"Каша"}"#, #"{"id":1,"name":"Каша","image":"https://evil.example/photo"}"#] {
            let model = RecipeEditorViewModel(importedRecipe: try importedRecipe(json), catalog: catalog)
            await model.loadImportedPhoto()
            XCTAssertFalse(model.remotePhotoFailed)
        }
        let model = RecipeEditorViewModel(importedRecipe: try importedRecipe(#"{"id":1,"name":"Каша","image":"https://vkusvill.ru/photo"}"#), catalog: catalog)
        model.isLoadingPhoto = true
        await model.loadImportedPhoto()
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testPhotoCancellationDoesNotShowFailureOrRetainLoadingFlag() async throws {
        let model = RecipeEditorViewModel(importedRecipe: try importedRecipe(#"{"id":1,"name":"Каша","image":"https://vkusvill.ru/photo"}"#), catalog: catalog)
        let task = Task { await model.loadImportedPhoto() }
        task.cancel()
        await task.value
        XCTAssertFalse(model.remotePhotoFailed)
        XCTAssertFalse(model.isLoadingPhoto)
        XCTAssertNil(model.photoData)
    }

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(for: Schema(AppSchema.models), configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
}
