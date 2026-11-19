import XCTest

struct FeedbackPage {
    let app: XCUIApplication

    var titleField: XCUIElement { app.textFields["feedback.title"] }
    var messageField: XCUIElement { app.textViews["feedback.message"] }
    var submitButton: XCUIElement { app.buttons["feedback.submit"] }

    func open() {
        app.tabBars.buttons["Настройки"].tap()
    }
}
