//
//  CityListViewModel.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import Observation
import Foundation

@MainActor
@Observable
public class CityListViewModel{
    public var savedCities: [City] = []
    public var savedCitiesWeather: [ForecastUI] = []
    public var savedCitiesWeatherError: [String : WeatherErrorUI] = [:]
    
    public var searchQuery: String = "" {
        didSet {
            searchCities()
        }
    }
    public var searchResults: [City] = []
    private var searchTask: Task<Void, Never>?
    
    public var cityListWeatherUIState: CityListUIState
    
    private let weatherRepository: WeatherRepository
    
    public init(weatherRepo: WeatherRepository){
        weatherRepository = weatherRepo
        savedCities = weatherRepository.LoadFavoriteCities()
        cityListWeatherUIState = .Loading
    }
    
    public func loadSavedCitiesWeather() async {

        var updatedList: [ForecastUI] = []
        savedCitiesWeatherError = [:]

        for city in savedCities { //Как сюда прокинуть selectedCity, чтобы лишний раз не обновлять его?
            let weather = await weatherRepository.GetWeatherForSelectedCity(for: city)
            switch weather{
                case .success(let currentForecast) :
                    updatedList.append(currentForecast)
                case .failure(let forecastError) :
                    savedCitiesWeatherError[city.name] = forecastError
                    
            }
        }

        if !updatedList.isEmpty {
            self.savedCitiesWeather = updatedList
            cityListWeatherUIState = .Success
        } else{
            cityListWeatherUIState = .Fail
        }
        
    }
    
    public func searchCities() {
        searchTask?.cancel()

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            self.searchResults = []
            return
        }
        
        cityListWeatherUIState = .Search
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            
            let results = await weatherRepository.SearchCities(query: query)
            guard !Task.isCancelled else { return }
            self.searchResults = results
            cityListWeatherUIState = .Success //Пока что здесь негативный сценарий не рассматривал
            
        }
    }
    
    /// Добавление города в избранное
    public func addCity(city: City) async {
        guard !savedCities.contains(where: { $0.name == city.name && $0.country == city.country }) else {
            return
        }
        
        var newCity = city
        savedCities.append(newCity)
        
        // Подгружаем сводку погоды для добавленного города
        let weather = await weatherRepository.GetWeatherForSelectedCity(for: newCity)
        switch weather{
            case .success(let currentForecast) :
                savedCitiesWeather.append(currentForecast)
            case .failure(let forecastError) :
                savedCitiesWeatherError[city.name] = forecastError
        }
    }
        
    /// Удаление города из избранного по индексу
    public func deleteCity(at offsets: IndexSet) {
        let citiesToDelete = offsets.map { savedCities[$0] }
        if savedCities.count > 1{ //Должен быть хотя бы 1 сохранённый город!
            for city in citiesToDelete{
                savedCities.removeAll { $0.id == city.id }
                savedCitiesWeather.removeAll { $0.city.id == city.id }
            }
        }
    }

    /// Проверка, добавлен ли уже город в список избранных
    public func isCitySaved(city: City) -> Bool {
        savedCities.contains(where: { $0.name == city.name && $0.country == city.country })
    }

}
