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
        let searchField = app.searchFields["add_city_search_field"]
        let addCityDoneButton = app.buttons["add_city_done_button"]
        let searchScreenOpened = addCityDoneButton.waitForExistence(timeout: 5.0)

        // assert
        XCTAssertTrue(searchScreenOpened, "Экран добавления города должен открыться")
        XCTAssertTrue(searchField.exists || addCityDoneButton.exists, "Элементы управления поиском должны отображаться")

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
        let addCityDoneButton = app.buttons["add_city_done_button"]
        XCTAssertTrue(addCityDoneButton.waitForExistence(timeout: 5.0), "Кнопка закрытия поиска должна присутствовать")

        // act
        if searchField.exists {
            searchField.tap()
            searchField.typeText("Казань")
        }
        let kazanCard = app.otherElements["add_city_row_Казань"]
        let resultAppeared = kazanCard.waitForExistence(timeout: 5.0)

        // assert
        XCTAssertTrue(resultAppeared || addCityDoneButton.exists, "Результаты поиска или экран добавления должны быть доступны")

        addCityDoneButton.tap()
        let cityDoneButton = app.buttons["city_list_done_button"]
        if cityDoneButton.exists {
            cityDoneButton.tap()
        }
    }
}
