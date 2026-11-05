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
    func testInvalidPhotoURLShowsMessageAndAllowsSaving() {
        let app = launchApp()
        app.buttons["Добавить"].tap()
        let title = app.textFields["Название"]
        title.tap()
        title.typeText("Photo URL test")

        let address = app.textFields["Ссылка на фото (https://…)"]
        XCTAssertTrue(address.waitForExistence(timeout: 5))
        address.tap()
        address.typeText("not-a-url")
        app.buttons["Загрузить по ссылке"].tap()

        let alert = app.alerts["Не удалось загрузить фото"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons["OK"].tap()
        XCTAssertTrue(app.buttons["Сохранить"].isEnabled)
        app.buttons["Сохранить"].tap()
        XCTAssertTrue(app.staticTexts["Photo URL test"].waitForExistence(timeout: 5))
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
