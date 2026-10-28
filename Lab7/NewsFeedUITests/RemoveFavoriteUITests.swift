import XCTest

final class RemoveFavoriteUITests: XCTestCase {
    @MainActor
    func testRemovingLastFavoriteShowsEmptyState() {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        let favoriteButton = app.buttons["favoriteButton_1"]
        let favoritesToggle = app.switches["favoritesToggle"].switches.firstMatch
        let firstTitle = app.staticTexts["newsTitle_1"]
        let secondTitle = app.staticTexts["newsTitle_2"]
        let emptyMessage = app.staticTexts["emptyNews"]

        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 5))
        XCTAssertTrue(secondTitle.waitForExistence(timeout: 5))

        favoriteButton.tap()

        XCTAssertTrue(
            favoriteButton.wait(
                for: \.label,
                toEqual: "Убрать из избранного",
                timeout: 5
            ),
            "Первая новость не добавилась в избранное"
        )

        XCTAssertTrue(favoritesToggle.waitForExistence(timeout: 5))
        favoritesToggle.tap()
        XCTAssertEqual(favoritesToggle.value as? String, "1")

        XCTAssertTrue(
            secondTitle.waitForNonExistence(timeout: 5),
            "После включения фильтра осталась неизбранная новость"
        )

        XCTAssertTrue(firstTitle.exists)

        favoriteButton.tap()

        XCTAssertTrue(
            emptyMessage.waitForExistence(timeout: 5),
            "После удаления последней избранной новости нет пустого состояния"
        )

        XCTAssertTrue(firstTitle.waitForNonExistence(timeout: 5))
    }
}
