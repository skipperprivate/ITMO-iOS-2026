//
//  CatalogUITests.swift
//  QuotelyUITests
//
//  Created by Egor Kuzminykh on 22.10.2026.
//

import XCTest

final class CatalogUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testSwitchingToCatalogTab() {
        XCTAssertTrue(app.navigationBars["Цитата дня"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Каталог"].tap()

        XCTAssertTrue(app.navigationBars["Каталог"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Загрузить"].exists)
    }

    @MainActor
    func testCatalogShowsEmptyStateAfterDeletingAllQuotes() {
        app.tabBars.buttons["Настройки"].tap()
        XCTAssertTrue(app.navigationBars["Настройки"].waitForExistence(timeout: 5))

        let deleteButton = app.buttons["Удалить все цитаты"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()

        app.tabBars.buttons["Каталог"].tap()

        let emptyState = app.staticTexts["Нет цитат. Нажмите «Загрузить»."]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 5))
    }
}
