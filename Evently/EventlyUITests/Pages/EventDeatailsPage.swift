import XCTest

struct EventDetailsPage {
    let app: XCUIApplication

    var favoriteButton: XCUIElement {
        app.buttons["eventDetails.favorite"]
    }

    var eventTitle: XCUIElement {
        app.staticTexts["Джазовый вечер"]
    }

    func addToFavorites() {
        favoriteButton.tap()
    }
}
