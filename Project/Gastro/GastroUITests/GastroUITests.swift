import XCTest

@MainActor
final class GastroUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    func testCreateRecipeAndReadItsDetails() {
        launch()
        openEditor()
        fillRecipe(title: "Test omelet")
        app.buttons["recipeEditor.save"].tap()
        let recipe = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Test omelet")).firstMatch
        XCTAssertTrue(recipe.waitForExistence(timeout: 5))
        recipe.tap()
        XCTAssertTrue(app.navigationBars["Test omelet"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Eggs"].exists)
        XCTAssertTrue(app.staticTexts["Mix and cook"].exists)
    }

    func testEditSavedRecipe() {
        launch()
        openEditor()
        fillRecipe(title: "Original recipe")
        app.buttons["recipeEditor.save"].tap()
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Original recipe")).firstMatch.tap()
        app.buttons["recipeDetail.edit"].tap()
        let title = app.textFields["recipeEditor.title"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        title.tap()
        let oldValue = title.value as? String ?? ""
        title.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: oldValue.count) + "Updated recipe")
        app.buttons["recipeEditor.save"].tap()
        XCTAssertTrue(app.navigationBars["Updated recipe"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Eggs"].exists)
    }

    func testMissingNameDoesNotCreateRecipe() {
        launch()
        openEditor()
        app.buttons["recipeEditor.save"].tap()
        let alert = app.alerts["Error"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.staticTexts["Enter a recipe name"].exists)
        alert.buttons["OK"].tap()
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.staticTexts["No recipes yet"].waitForExistence(timeout: 5))
    }

    func testPublishShowsLoadingAndReenablesButton() {
        launch()
        openEditor()
        fillRecipe(title: "Publish recipe")
        let publish = app.buttons["recipeEditor.publish"]
        publish.tap()
        XCTAssertTrue(app.activityIndicators["recipeEditor.publishing"].waitForExistence(timeout: 5))
        XCTAssertFalse(publish.isEnabled)
        XCTAssertFalse(app.buttons["recipeEditor.save"].isEnabled)
        let finished = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: publish)
        XCTAssertEqual(XCTWaiter.wait(for: [finished], timeout: 15), .completed)
        XCTAssertFalse(app.activityIndicators["recipeEditor.publishing"].exists)
        XCTAssertFalse(app.alerts.firstMatch.exists)
        XCTAssertFalse(app.staticTexts["toast.message"].exists)
        XCTAssertTrue(app.navigationBars["New recipe"].exists)
    }

    func testServerErrorToastCanBeDismissed() {
        launch()
        app.buttons["home.profile"].tap()
        app.buttons["profile.networkExamples"].tap()
        app.buttons["networkExamples.500"].tap()
        let toast = app.staticTexts["toast.message"]
        XCTAssertTrue(toast.waitForExistence(timeout: 5))
        XCTAssertEqual(toast.label, "Ошибка сервера (HTTP 500). Попробуйте позже.")
        app.buttons["toast.dismiss"].tap()
        let dismissed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: toast)
        XCTAssertEqual(XCTWaiter.wait(for: [dismissed], timeout: 2), .completed)
    }

    private func launch() {
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.buttons["home.recipes"].waitForExistence(timeout: 10))
    }

    private func openEditor() {
        app.buttons["home.recipes"].tap()
        let add = app.buttons["recipes.add"]
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        add.tap()
        XCTAssertTrue(app.textFields["recipeEditor.title"].waitForExistence(timeout: 5))
    }

    private func fillRecipe(title: String) {
        app.textFields["recipeEditor.title"].tap()
        app.textFields["recipeEditor.title"].typeText(title)
        app.textFields["recipeEditor.ingredient.0"].tap()
        app.textFields["recipeEditor.ingredient.0"].typeText("Eggs")
        let step = app.descendants(matching: .any).matching(identifier: "recipeEditor.step.0").firstMatch
        if !step.isHittable { app.swipeUp() }
        step.tap()
        step.typeText("Mix and cook")
    }
}
