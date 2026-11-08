import XCTest

final class WeatherlyUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        return app
    }

    @MainActor
    func testApplicationLaunches() {
        let app = launchApp()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["home.settings"].exists)
        XCTAssertTrue(app.buttons["home.places"].exists)
    }

    @MainActor
    func testUserCanOpenSettings() {
        let app = launchApp()
        let settingsButton = app.buttons["home.settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
        settingsButton.tap()

        XCTAssertTrue(app.navigationBars["Настройки"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Температура"].exists)
        XCTAssertTrue(app.staticTexts["Сила ветра"].exists)
        XCTAssertTrue(app.staticTexts["Давление"].exists)
        XCTAssertTrue(app.staticTexts["Оформление"].exists)
    }

    @MainActor
    func testUserCanOpenPlacesAndSeeSearchField() {
        let app = launchApp()
        let placesButton = app.buttons["home.places"]
        XCTAssertTrue(placesButton.waitForExistence(timeout: 10))
        placesButton.tap()

        XCTAssertTrue(app.navigationBars["Места"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["places.search"].exists)
    }

    @MainActor
    func testSearchFieldAcceptsText() {
        let app = launchApp()
        let placesButton = app.buttons["home.places"]
        XCTAssertTrue(placesButton.waitForExistence(timeout: 10))
        placesButton.tap()
        let searchField = app.textFields["places.search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("К")
        XCTAssertEqual(searchField.value as? String, "К")
    }

    @MainActor
    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
