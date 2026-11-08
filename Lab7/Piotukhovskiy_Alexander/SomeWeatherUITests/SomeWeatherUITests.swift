import XCTest

final class SomeWeatherUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
    }

    
    func testFirstLaunchShowsCitySelection() {
        XCTAssertTrue(app.navigationBars["Выберите город"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Выберите город, чтобы посмотреть погоду."].exists)
        XCTAssertTrue(app.searchFields["Название города"].exists)
    }

    
    func testOneLetterShowsValidationHint() {
        let searchField = app.searchFields["Название города"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))

        searchField.tap()
        searchField.typeText("М")

        XCTAssertTrue(app.staticTexts["Введите минимум 2 символа"].waitForExistence(timeout: 2))
    }
}
