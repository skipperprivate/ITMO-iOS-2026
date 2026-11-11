//
//  CityManagementTestsUI.swift
//  Wetaher_app_IOSTestsUI
//

import XCTest

final class CityManagementTestsUI: XCTestCase {

    /// Проверка открытия экрана списка городов и выбора сохраненного города
    func testOpenCityListAndSelectCity() throws {
        // arrange
        let app = XCUIApplication()
        app.launch()
        let cityListButton = app.buttons["main_city_list_button"]
        XCTAssertTrue(cityListButton.waitForExistence(timeout: 5.0), "Кнопка списка городов должна присутствовать на экране")

        // act
        cityListButton.tap()
        let cityDoneButton = app.buttons["city_list_done_button"]
        let listOpened = cityDoneButton.waitForExistence(timeout: 5.0)
        let saintPetersburgCard = app.otherElements["city_card_Санкт-Петербург"]

        if saintPetersburgCard.exists {
            saintPetersburgCard.tap()
        } else {
            cityDoneButton.tap()
        }

        // assert
        XCTAssertTrue(listOpened, "Шторка списка избранных городов должна успешно открыться")
        let cityTitle = app.staticTexts["main_current_city_title"]
        XCTAssertTrue(cityTitle.waitForExistence(timeout: 5.0), "Главный экран должен отобразить прогноз после выбора города")
    }

    /// Проверка перехода на экран поиска нового города
    func testOpenAddCityScreen() throws {
        // arrange
        let app = XCUIApplication()
        app.launch()
        let cityListButton = app.buttons["main_city_list_button"]
        XCTAssertTrue(cityListButton.waitForExistence(timeout: 5.0), "Кнопка списка городов должна присутствовать")
        cityListButton.tap()
        let addCityButton = app.buttons["city_list_add_button"]
        XCTAssertTrue(addCityButton.waitForExistence(timeout: 5.0), "Кнопка добавления города должна присутствовать")

        // act
        addCityButton.tap()
        // У `.searchable` нет собственного accessibility identifier — берём первый search field
        let searchField = app.searchFields.firstMatch
        let addCityDoneButton = app.buttons["add_city_done_button"]
        let searchScreenOpened = addCityDoneButton.waitForExistence(timeout: 5.0)

        // assert
        XCTAssertTrue(searchScreenOpened, "Экран добавления города должен открыться")
        XCTAssertTrue(searchField.waitForExistence(timeout: 5.0), "Поле поиска должно отображаться")

        addCityDoneButton.tap()
        let cityDoneButton = app.buttons["city_list_done_button"]
        if cityDoneButton.exists {
            cityDoneButton.tap()
        }
    }

    /// Проверка поиска города и добавления в избранное
    func testSearchCityAndToggleFavorite() throws {
        // arrange
        let app = XCUIApplication()
        app.launch()
        let cityListButton = app.buttons["main_city_list_button"]
        XCTAssertTrue(cityListButton.waitForExistence(timeout: 5.0), "Кнопка списка городов должна присутствовать")
        cityListButton.tap()
        let addCityButton = app.buttons["city_list_add_button"]
        XCTAssertTrue(addCityButton.waitForExistence(timeout: 5.0), "Кнопка добавления города должна присутствовать")
        addCityButton.tap()

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5.0), "Поле поиска должно присутствовать")

        // act
        searchField.tap()
        searchField.typeText("Казань")

        // Поиск идёт в сеть с дебаунсом.
        // Кнопка-toggle появляется только вместе со строкой результата, поэтому по ней проверяем и сам результат поиска
        let toggleButton = app.buttons["add_city_toggle_Казань"].firstMatch

        // assert
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 10.0), "Результат поиска должен появиться")

        let labelBeforeTap = toggleButton.label
        toggleButton.tap()

        // Состояние избранного переключается: подпись кнопки должна измениться
        let predicate = NSPredicate(format: "label != %@", labelBeforeTap)
        expectation(for: predicate, evaluatedWith: toggleButton)
        waitForExpectations(timeout: 5.0)
    }
}
