//
//  Weather_app_IOSFailResponseTests.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 29.10.2026.
//

import XCTest

@testable import Wetaher_app_IOS

@MainActor
final class Wetaher_app_IOSFailResponseTests: XCTestCase {
    
    var weatherVM: WeatherMainViewModel!
    var cityListVM: CityListViewModel!
    var weatherRep: WeatherRepository!
    
    override func setUp() {
        super.setUp()
        weatherRep = MockRepositoryFailResponseImpl()
        weatherVM = WeatherMainViewModel(weatherRepo: weatherRep)
        cityListVM = CityListViewModel(weatherRepo: weatherRep)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        weatherRep = nil
        weatherVM = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func test_initialLoad_failure_setsWeatherState() async {

        // Act
        await weatherVM.loadWeather()

        // Assert
        guard case .Fail(let weatherError) = weatherVM.weatherUIState else {
            return XCTFail("Ожидалось состояние .Fail, получено: \(weatherVM.weatherUIState)")
        }

        XCTAssertEqual(weatherError.errorCode, 67)
        XCTAssertFalse(weatherVM.isLoadingStarted)
        XCTAssertFalse(weatherVM.isCascadeUpdateForbidden)
    }
    
    @MainActor
    func test_initialLoad_failure_SavedCitiesWeatherState() async {

        await cityListVM.loadSavedCitiesWeather(selectedCityForecast: .moskowWeather)

        XCTAssertEqual(cityListVM.cityListWeatherUIState, .Success)
        XCTAssertEqual(cityListVM.addCityUIState, .Success([]))
        XCTAssertEqual(cityListVM.savedCitiesWeather.first?.city, .moscow)
        XCTAssertEqual(cityListVM.savedCitiesWeatherError.count, 1)
    }
    
    @MainActor
    func test_failure_searchCities() async {

        cityListVM.searchCities(query: "Новосиб")

        XCTAssertEqual(cityListVM.addCityUIState, .Search)
        await cityListVM.searchTask?.value

        guard case .Fail(let citySearchFail) = cityListVM.addCityUIState else {
                return XCTFail("Ожидалось .Fail, получено: \(cityListVM.addCityUIState)")
            }

        XCTAssertEqual(citySearchFail.errorId, 69)
    }
}
