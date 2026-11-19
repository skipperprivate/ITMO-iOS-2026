import XCTest

final class EventlyUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingOpensMainScreen() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-ui-testing-onboarding"]
        app.launch()

        let onboarding = OnboardingPage(app: app)
        XCTAssertTrue(onboarding.continueButton.waitForExistence(timeout: 5))
        onboarding.finish()

        XCTAssertTrue(app.tabBars.buttons["Главная"].waitForExistence(timeout: 5))
        XCTAssertFalse(onboarding.continueButton.exists)
    }

    @MainActor
    func testFeedbackFormValidation() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        let feedback = FeedbackPage(app: app)
        feedback.open()
        XCTAssertTrue(feedback.submitButton.waitForExistence(timeout: 5))
        XCTAssertFalse(feedback.submitButton.isEnabled)

        feedback.titleField.tap()
        feedback.titleField.typeText("Ошибка")
        XCTAssertFalse(feedback.submitButton.isEnabled)

        feedback.messageField.tap()
        feedback.messageField.typeText("Не загружается список")
        XCTAssertTrue(feedback.submitButton.isEnabled)
    }
    @MainActor
    func testAddAndRemoveFavorite() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        let home = HomePage(app: app)
        let details = EventDetailsPage(app: app)
        let favorites = FavoritesPage(app: app)

        XCTAssertTrue(home.eventCard.waitForExistence(timeout: 5))
        home.openEvent()
        XCTAssertTrue(details.eventTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(details.favoriteButton.exists)
        details.addToFavorites()
        XCTAssertEqual(details.favoriteButton.label, "Удалить из избранного")
        favorites.open()
        XCTAssertTrue(favorites.eventCard.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Джазовый вечер"].exists)
        XCTAssertTrue(favorites.deleteButton.waitForExistence(timeout: 5), "Кнопка удаления не найдена")
        favorites.deleteEvent()
        XCTAssertTrue(favorites.emptyState.waitForExistence(timeout: 5))
        XCTAssertFalse(favorites.eventCard.exists)
    }
}
