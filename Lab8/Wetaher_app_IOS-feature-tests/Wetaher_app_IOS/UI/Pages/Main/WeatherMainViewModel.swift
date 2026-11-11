//
//  WeatherMainViewModel.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//
import Observation

@MainActor
@Observable
public class WeatherMainViewModel {
    private let weatherRepository: WeatherRepository

    public var selectedCity: City
    public var weatherUIState: WeatherUIState
    public var isLoadingStarted: Bool = false
    public var isCascadeUpdateForbidden = false

    public init(weatherRepo: WeatherRepository, initalValue: City = .moscow) {
        weatherRepository = weatherRepo
        selectedCity = initalValue
        weatherUIState = .Loading

        if !TestChecker.isRunningTests {
            Task {// Убирать можно только в случае, если хотите дудосить API
                await loadWeather()
            }
        }

    }

    public func loadWeather(addNewCity: Bool = false) async {
        guard !isLoadingStarted else { return }
        isCascadeUpdateForbidden =
            if addNewCity {
                true
            }else {
                false
            }

        isLoadingStarted = true

        let weather = await weatherRepository.GetWeatherForSelectedCity(for: selectedCity)

        switch weather {
            case .success(let currentForecast):
            weatherUIState = .Success(currentForecast.ToUI(city: selectedCity)) // Нужен ли здесь City?
            case .failure(let forecastError):
            weatherUIState = .Fail(forecastError.ToUI())
        }

        isLoadingStarted = false
    }

    public func refeshWeatherWrapper() {
        Task {
            await refreshWeather()
        }
    }

    public func refreshWeather() async {
        weatherUIState = .Loading

        await loadWeather()
    }

    public func selectCityWrapper(newCity: CityWeatherState) {
        Task {
            await selectCity(newCity: newCity)
        }
    }

    public func selectCity(newCity: CityWeatherState) async {
        var city: City
        switch newCity {
        case .CityWithWeather(let cityWeather):
            city = cityWeather.city
            guard city.id != selectedCity.id else { return } // Не очень понимаю как правильно читать guard
            self.selectedCity = city
            weatherUIState = .Success(cityWeather)

        case .NewCity(let addedCity):
            city = addedCity
            guard city.id != selectedCity.id else { return }
            self.selectedCity = city

            weatherUIState = .Loading
            await loadWeather(addNewCity: true)

        }
    }

}
