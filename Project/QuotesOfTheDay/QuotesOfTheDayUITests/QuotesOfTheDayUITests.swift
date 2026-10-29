import XCTest

final class QuotesOfTheDayUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOpenSettings() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Настройки"].tap()

        XCTAssertTrue(
            app.navigationBars["Настройки"].exists
        )
    }

    func testOpenQuoteDetail() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Все цитаты"].tap()

        let firstQuote = app.cells.element(boundBy: 0)

        XCTAssertTrue(
            firstQuote.waitForExistence(timeout: 10)
        )

        firstQuote.tap()

        XCTAssertTrue(
            app.navigationBars["Цитата"].waitForExistence(timeout: 5)
        )
    }
}
