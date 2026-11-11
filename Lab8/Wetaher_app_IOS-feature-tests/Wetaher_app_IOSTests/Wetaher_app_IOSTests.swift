//
//  Wetaher_app_IOSTests.swift
//  Wetaher_app_IOSTests
//
//  Created by Roman Zyuzin on 22.10.2026.
//

import XCTest

@testable import Wetaher_app_IOS

@MainActor
final class Wetaher_app_IOSTests: XCTestCase {

    var settingsVM: SettingsViewModel!
    var weatherVM: WeatherMainViewModel!
    var cityListVM: CityListViewModel!
    var weatherRep: WeatherRepository!

    override func setUp() {
        super.setUp()
        weatherRep = MockRepositoryImpl()
        weatherVM = WeatherMainViewModel(weatherRepo: weatherRep)
        cityListVM = CityListViewModel(weatherRepo: weatherRep)
        settingsVM = SettingsViewModel(weatherRepo: weatherRep)

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        weatherRep = nil
        settingsVM = nil
        weatherVM = nil
        settingsVM = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //Важно: тесты независимы друг от друга, поэтому изменения от init, инициированные одним тестом в другом не видны!
    /// Initial tests
    @MainActor
    func test_init_setsSystemTheme() {
        XCTAssertEqual(settingsVM.appTheme, .system)
    }

    @MainActor
    func test_init_setsSelected_City() {
        XCTAssertEqual(weatherVM.selectedCity, .moscow)
    }

    @MainActor
    func test_init_setsWeatherState() {
        XCTAssertEqual(weatherVM.weatherUIState, .Loading)
    }

    @MainActor
    func test_init_setsCityListSavedCities() {
        XCTAssertEqual(cityListVM.savedCities, City.defaultFavorites)
    }

    @MainActor
    func test_init_setsCityListWeatherUIState() {
        XCTAssertEqual(cityListVM.cityListWeatherUIState, .Loading)
    }

    @MainActor
    func test_init_setsAddCityUiState() {
        XCTAssertEqual(cityListVM.addCityUIState, .Loading)
    }

    /// Initial load tests
    @MainActor
    func test_initialLoad_success_setsWeatherState() async {
        // Arrange
        let expectedForecast = WeatherResponse.moscowWeatherResp

        // Act
        await weatherVM.loadWeather()

        // Assert
        guard case .Success(let cityWeather) = weatherVM.weatherUIState else {
            return XCTFail("Ожидалось состояние .Success, получено: \(weatherVM.weatherUIState)")
        }

        XCTAssertEqual(cityWeather.city.id, City.moscow.id)
        XCTAssertEqual(cityWeather, expectedForecast.ToUI(city: .moscow))
        XCTAssertFalse(weatherVM.isLoadingStarted)
        XCTAssertFalse(weatherVM.isCascadeUpdateForbidden)
    }

    @MainActor
    func test_initialLoad_success_SavedCitiesWeatherState() async {

        let spbWeather: WeatherResponse = .saintPetersburgWeatherResp
        let expectedForecast: [ForecastUI] = [.moskowWeather, spbWeather.ToUI(city: .saintPetersburg)]

        await cityListVM.loadSavedCitiesWeather(selectedCityForecast: .moskowWeather)

        XCTAssertEqual(cityListVM.cityListWeatherUIState, .Success)
        XCTAssertEqual(cityListVM.addCityUIState, .Success([]))
        XCTAssertEqual(cityListVM.savedCitiesWeather, expectedForecast)
        XCTAssertEqual(cityListVM.savedCitiesWeatherError, [:])
    }

    /// WeatherMainViewModel Events Tests
    @MainActor
    func test_refreshLoad_WeatherState() async {

        let expectedForecast = WeatherResponse.moscowWeatherResp

        await weatherVM.refreshWeather()

        guard case .Success(let cityWeather) = weatherVM.weatherUIState else {
            return XCTFail("Ожидалось состояние .Success, получено: \(weatherVM.weatherUIState)")
        }

        XCTAssertEqual(cityWeather.city.id, City.moscow.id)
        XCTAssertEqual(cityWeather, expectedForecast.ToUI(city: .moscow))
        XCTAssertFalse(weatherVM.isLoadingStarted)
        XCTAssertFalse(weatherVM.isCascadeUpdateForbidden)
    }

    @MainActor
    func test_selectAddedCity() async {

        await weatherVM.selectCity(newCity: .CityWithWeather(.saintPetersburgWeather))

        guard case .Success(let cityWeather) = weatherVM.weatherUIState else {
            return XCTFail("Ожидалось состояние .Success, получено: \(weatherVM.weatherUIState)")
        }

        XCTAssertEqual(cityWeather.city.id, City.saintPetersburg.id)
        XCTAssertEqual(cityWeather, ForecastUI.saintPetersburgWeather)
        XCTAssertFalse(weatherVM.isLoadingStarted)
        XCTAssertFalse(weatherVM.isCascadeUpdateForbidden)

        XCTAssertEqual(weatherVM.selectedCity, .saintPetersburg)
    }

    @MainActor
    func test_selectNewCity() async {
        let expectedForecast = WeatherResponse.kazanWeatherResp

        await weatherVM.selectCity(newCity: .NewCity(.kazan))

        guard case .Success(let cityWeather) = weatherVM.weatherUIState else {
            return XCTFail("Ожидалось состояние .Success, получено: \(weatherVM.weatherUIState)")
        }

        XCTAssertEqual(cityWeather.city.id, City.kazan.id)
        XCTAssertEqual(cityWeather, expectedForecast.ToUI(city: .kazan))
        XCTAssertFalse(weatherVM.isLoadingStarted)
        XCTAssertTrue(weatherVM.isCascadeUpdateForbidden)

        XCTAssertEqual(weatherVM.selectedCity, .kazan)
    }

    /// CityListViewModel Events Tests
    @MainActor
    func test_searchCities() async {

        let expectedCity: City = .novosibirsk
        cityListVM.searchCities(query: "Новосиб")

        XCTAssertEqual(cityListVM.addCityUIState, .Search)
        await cityListVM.searchTask?.value

        guard case .Success(let cities) = cityListVM.addCityUIState else {
                return XCTFail("Ожидалось .Success, получено: \(cityListVM.addCityUIState)")
            }

        XCTAssertFalse(cities.isEmpty)
        XCTAssertEqual(cities.first?.id, expectedCity.id)
    }

    @MainActor
    func test_searchCities_QueryEmpty() {

        cityListVM.searchCities(query: "")

        XCTAssertEqual(cityListVM.addCityUIState, .Success([]))
    }

    @MainActor
    func test_AddCity() async {
        let expectedWeather: WeatherResponse = .novosibirskWeatherResp
        let expectedCity: City = .novosibirsk

        await cityListVM.addCity(city: .novosibirsk)

        if !cityListVM.savedCities.contains(.novosibirsk) {
            XCTFail("В список сохранённых городов не добавился новый город")
        }

        let addedCityWeather = cityListVM.savedCitiesWeather.first(where: {cityForecast in cityForecast.city == .novosibirsk})

        if addedCityWeather == nil {
            XCTFail("У добавленного города нет прогноза погоды")
        }

        if cityListVM.savedCitiesWeatherError.keys.contains(expectedCity.name) {
            XCTFail("У добавленного города ложно добавилась ForecastError")
        }

        XCTAssertEqual(addedCityWeather, expectedWeather.ToUI(city: .novosibirsk))
    }
    
    @MainActor
    func test_DeleteCity(){
        
        let returnedSelectedCity = cityListVM.deleteCity(city: .saintPetersburg)
        
        if cityListVM.savedCities.contains(.saintPetersburg) {
            XCTFail("В списке сохранённых городов не удалился удалённый город")
        }
        
        if !cityListVM.savedCities.contains(returnedSelectedCity.city){
            XCTFail("В качестве нового выбранного города был возвращён город не из списка выбранных")
        }
    }
    
    @MainActor
    func test_IsCitySaved(){
        var returnedResult = cityListVM.isCitySaved(city: .saintPetersburg)
        XCTAssertEqual(returnedResult, true)
        
        returnedResult = cityListVM.isCitySaved(city: .kaliningrad)
        XCTAssertEqual(returnedResult, false)
    }
}
