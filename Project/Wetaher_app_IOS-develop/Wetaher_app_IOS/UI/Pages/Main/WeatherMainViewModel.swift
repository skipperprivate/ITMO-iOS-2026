//
//  WeatherMainViewModel.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//
import Foundation
import Observation

@MainActor
@Observable
public class WeatherMainViewModel {
    private let weatherRepository: WeatherRepository
    private let cityRepository: CityRepository

    public var selectedCity: City
    public var weatherUIState: WeatherUIState
    public var isLoadingStarted: Bool = false
    public var isCascadeUpdateForbidden = false

    public var isFromCache = false
    public var cacheUpdatedAt: Date?

    public init(
        weatherRepo: WeatherRepository,
        cityRepo: CityRepository,
        initalValue: City? = nil
    ){
        weatherRepository = weatherRepo
        cityRepository = cityRepo

        let favorites = cityRepository.LoadSavedCities()
        let activeCityID = cityRepository.LoadActiveCityID()
        let storedCity = favorites.first { $0.id == activeCityID }
        selectedCity = initalValue ?? storedCity?.toUI() ?? favorites.first?.toUI() ?? .moscow
        weatherUIState = .Loading

        cityRepository.SetActiveCity(selectedCity.id)

        if !TestChecker.isRunningTests {
            Task {// Убирать можно только в случае, если хотите дудосить API
                await loadWeather()
            }
        }

    }

    public var cacheAgeDescription: String? {
        guard let cacheUpdatedAt else { return nil }

        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: cacheUpdatedAt, relativeTo: Date())
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
        switch weather{
        case .success(let snapshot) :
            isFromCache = snapshot.isFromCache
            cacheUpdatedAt = snapshot.savedAt
            weatherUIState = .Success(snapshot.entity.toUI())
        case .failure(let forecastError) :
            isFromCache = false
            cacheUpdatedAt = nil
            weatherUIState = .Fail(forecastError.toUI())
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

    public func selectCity(newCity: CityWeatherState) async {
        var city: City
        switch newCity {
        case .CityWithWeather(let cityWeather):
            city = cityWeather.city
            guard city.id != selectedCity.id else { return }
            self.selectedCity = city
            cityRepository.SetActiveCity(city.id)
            isFromCache = false
            cacheUpdatedAt = nil
            weatherUIState = .Success(cityWeather)

        case .NewCity(let addedCity):
            city = addedCity
            guard city.id != selectedCity.id else { return }
            self.selectedCity = city
            cityRepository.SetActiveCity(city.id)

            weatherUIState = .Loading
            await loadWeather(addNewCity: true)

        }
    }
    
    public func selectCityWrapper(newCity: CityWeatherState) {
        Task {
            await selectCity(newCity: newCity)
        }
    }

    // Обновление кэша перед уходом приложения в фон
    public func prepareForOffline() {
        let city = selectedCity

        Task { [weak self] in
            _ = await self?.weatherRepository.GetWeatherForSelectedCity(for: city)
        }
    }

}
