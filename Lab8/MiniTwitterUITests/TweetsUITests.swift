import XCTest

final class TweetsUITests: XCTestCase {
    @MainActor
    func testCreateLocalTweetFromHome() {
        continueAfterFailure = false
        let app = launchFeed()

        let compose = app.buttons["feed.compose"]
        XCTAssertTrue(compose.waitForExistence(timeout: 10))
        waitUntilEnabled(compose)
        compose.tap()

        let editor = app.textViews["editor.text"]
        let save = app.buttons["editor.save"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        XCTAssertTrue(save.exists)
        XCTAssertFalse(save.isEnabled)

        let text = "Мой новый локальный твит"
        editor.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        editor.typeText(text)
        waitForValue(text, on: editor)
        waitUntilEnabled(save)
        save.tap()

        XCTAssertTrue(editor.waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[text].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Локальный твит"].exists)
    }

    @MainActor
    func testFavoritesFilterAndRemoval() {
        continueAfterFailure = false
        let app = launchFeed()

        let firstID = "11111111-1111-1111-1111-111111111111"
        let secondID = "22222222-2222-2222-2222-222222222222"
        let first = app.staticTexts["tweet.text.\(firstID)"]
        let second = app.staticTexts["tweet.text.\(secondID)"]
        let bookmark = app.buttons["tweet.favorite.\(firstID)"]
        XCTAssertTrue(first.waitForExistence(timeout: 10))
        XCTAssertTrue(second.exists)
        XCTAssertEqual(bookmark.value as? String, "unselected")
        waitUntilEnabled(bookmark)
        bookmark.tap()
        waitForValue("selected", on: bookmark)

        let filter = app.segmentedControls["feed.filter"]
        XCTAssertTrue(filter.exists)
        filter.buttons["Избранное"].tap()
        XCTAssertTrue(second.waitForNonExistence(timeout: 5))
        XCTAssertTrue(first.exists)

        waitUntilEnabled(bookmark)
        bookmark.tap()
        XCTAssertTrue(first.waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["feed.empty"].waitForExistence(timeout: 5))

        filter.buttons["Все"].tap()
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        XCTAssertTrue(second.exists)
        XCTAssertEqual(bookmark.value as? String, "unselected")
    }

    @MainActor
    private func launchFeed() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        let link = app.buttons["menu.house.fill"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        link.tap()
        return app
    }

    @MainActor
    private func waitUntilEnabled(_ element: XCUIElement) {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true AND enabled == true AND hittable == true"),
            object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
    }

    @MainActor
    private func waitForValue(_ value: String, on element: XCUIElement) {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", value), object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
    }
}
