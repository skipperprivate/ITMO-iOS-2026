import XCTest

struct OnboardingPage {
    let app: XCUIApplication

    var continueButton: XCUIElement { app.buttons["onboarding.continue"] }

    func finish() {
        continueButton.tap()
    }
}
