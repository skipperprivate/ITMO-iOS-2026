import XCTest

final class FavoritesFilterUITests: XCTestCase {
    @MainActor
    func testFavoritesFilterShowsEmptyState() {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        let toggle = app.switches["favoritesToggle"].switches.firstMatch

        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.tap()
        XCTAssertEqual(toggle.value as? String, "1")

        XCTAssertTrue(
            app.staticTexts["emptyNews"]
                .waitForExistence(timeout: 5)
        )

        XCTAssertFalse(app.staticTexts["newsTitle_1"].exists)
    }
}
