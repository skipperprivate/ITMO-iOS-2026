import XCTest

struct HomePage {
    let app: XCUIApplication

    private let eventID =
        "00000000-0000-0000-0000-000000000006"

    var eventCard: XCUIElement {
        app.buttons["home.event.\(eventID)"]
    }

    func openEvent() {
        if !eventCard.isHittable {
            app.swipeUp()
        }

        eventCard.tap()
    }
}
