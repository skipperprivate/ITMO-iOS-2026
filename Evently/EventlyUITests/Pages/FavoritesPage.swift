import XCTest

struct FavoritesPage {
    let app: XCUIApplication

    private let eventID =
        "00000000-0000-0000-0000-000000000006"

    var tab: XCUIElement {
        app.tabBars.buttons["Избранное"]
    }

    var eventCard: XCUIElement {
        app.descendants(matching: .any)[
            "favorites.event.\(eventID)"
        ]
    }

    var deleteButton: XCUIElement {
        eventCard.buttons[
            "favorites.delete.\(eventID)"
        ]
    }

    var emptyState: XCUIElement {
        app.staticTexts["Нет избранных событий"]
    }

    func open() {
        tab.tap()
    }

    func deleteEvent() {
        deleteButton.tap()
    }
}
