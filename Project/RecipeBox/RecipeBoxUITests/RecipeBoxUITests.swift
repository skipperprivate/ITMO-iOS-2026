//
//  RecipeBoxUITests.swift
//  RecipeBoxUITests
//
//  Created by Nikita Makhov on 15.10.2026.
//

import XCTest

final class RecipeBoxUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTabsExist() throws {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
        XCTAssertTrue(tabBar.buttons["Главная"].exists)
        XCTAssertTrue(tabBar.buttons["Рецепты"].exists)
        XCTAssertTrue(tabBar.buttons["Понравившиеся"].exists)
        XCTAssertTrue(tabBar.buttons["Мои рецепты"].exists)

        tabBar.buttons["Рецепты"].tap()
        tabBar.buttons["Понравившиеся"].tap()
        tabBar.buttons["Мои рецепты"].tap()
        tabBar.buttons["Главная"].tap()
    }
}
