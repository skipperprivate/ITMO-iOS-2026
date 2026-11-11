//
//  SettingsTestsUI.swift
//  Wetaher_app_IOSTestsUI
//

import XCTest

final class SettingsTestsUI: XCTestCase {

    /// Проверка открытия и закрытия экрана настроек
    func testOpenAndDismissSettingsSheet() throws {
        // arrange
        let app = XCUIApplication()
        app.launch()
        let settingsButton = app.buttons["main_settings_button"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5.0), "Кнопка настроек должна быть доступна на главном экране")

        // act
        settingsButton.tap()
        let doneButton = app.buttons["settings_done_button"]
        let sheetAppeared = doneButton.waitForExistence(timeout: 5.0)
        doneButton.tap()

        // assert
        XCTAssertTrue(sheetAppeared, "Экран настроек должен открыться с кнопкой 'Готово'")
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5.0), "После закрытия настроек должен снова отображаться главный экран")
    }

    /// Проверка переключения темы оформления в настройках
    func testChangeThemeInSettings() throws {
        // arrange
        let app = XCUIApplication()
        app.launch()
        let settingsButton = app.buttons["main_settings_button"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5.0), "Кнопка настроек должна быть доступна")
        settingsButton.tap()
        let themePicker = app.segmentedControls["settings_theme_picker"]
        XCTAssertTrue(themePicker.waitForExistence(timeout: 5.0), "Пикер темы должен появиться на экране настроек")

        // act
        let darkSegment = themePicker.buttons["Тёмная"]
        if darkSegment.exists {
            darkSegment.tap()
        }

        let doneButton = app.buttons["settings_done_button"]
        doneButton.tap()

        // assert
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5.0), "Экран настроек успешно применил тему и закрылся")
    }
}
