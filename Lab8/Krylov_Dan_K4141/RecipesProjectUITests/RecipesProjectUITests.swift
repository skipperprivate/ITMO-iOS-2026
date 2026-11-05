import XCTest

class RecipesProjectUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCreateAndSearchRecipe() {
        let app = launchApp()
        createRecipe("Omelet", in: app)
        createRecipe("Borsch", in: app)

        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("Omel")

        XCTAssertTrue(app.staticTexts["Omelet"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Borsch"].waitForNonExistence(timeout: 3))
    }

    @MainActor
    func testFavoriteFilter() {
        let app = launchApp()
        createRecipe("Syrniki", in: app)
        createRecipe("Kasha", in: app)

        app.staticTexts["Syrniki"].tap()
        app.buttons["Избранное"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        app.buttons["Фильтры"].tap()
        app.buttons["Только избранное"].tap()

        XCTAssertTrue(app.staticTexts["Syrniki"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Kasha"].waitForNonExistence(timeout: 3))
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        return app
    }

    @MainActor
    private func createRecipe(_ title: String, in app: XCUIApplication) {
        app.buttons["Добавить"].tap()
        let field = app.textFields["Название"]
        field.tap()
        field.typeText(title)
        app.buttons["Сохранить"].tap()
    }
}
