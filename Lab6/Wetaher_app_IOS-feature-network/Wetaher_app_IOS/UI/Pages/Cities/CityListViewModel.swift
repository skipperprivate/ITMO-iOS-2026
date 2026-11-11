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
    
//    public var searchQuery: String = "" {
//        didSet {
//            searchCities()
//        }
//    }
    //public var searchResults: [City] = []
    private var searchTask: Task<Void, Never>?
    
    public var cityListWeatherUIState: CityListUIState
    public var addCityUIState: AddCityUIState
    
    
    private let weatherRepository: WeatherRepository
    
    public init(weatherRepo: WeatherRepository){
        weatherRepository = weatherRepo
        savedCities = weatherRepository.LoadFavoriteCities()
        cityListWeatherUIState = .Loading
        addCityUIState = .Loading
    }
    
    public func loadSavedCitiesWeather(selectedCityForecast: ForecastUI) {
        
        let selectedCity = selectedCityForecast.city

        var updatedList: [ForecastUI] = []
        savedCitiesWeatherError = [:]

        Task{
            for city in savedCities { //Cюда прокидывается selectedCity, чтобы лишний раз не запрашивать уже запрошенный город
                if(city.id == selectedCity.id){
                    updatedList.append(selectedCityForecast)
                }else{
                    let weather = await weatherRepository.GetWeatherForSelectedCity(for: city)
                    
                    switch weather{
                    case .success(let currentForecast) :
                        updatedList.append(currentForecast.ToUI(city: city))
                    case .failure(let forecastError) :
                        savedCitiesWeatherError[city.name] = forecastError.ToUI()
                    }
                }
            }
            
            self.savedCitiesWeather = updatedList
            if !updatedList.isEmpty {
                cityListWeatherUIState = .Success
            } else {
                cityListWeatherUIState = .Fail
            }
            
            addCityUIState = .Success([])
        }
    }
    
    public func searchCities(query: String) {
        //Предлагаю разрешать п-лю искать и добавлять новые города только когда у нас менее 9 избранных!
        
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            //self.searchResults = []
//            if cityListWeatherUIState == .Search {
//                cityListWeatherUIState = savedCitiesWeather.isEmpty && !savedCities.isEmpty ? .Fail : .Success
//            }
            addCityUIState = .Success([])
            //return searchResults
        }
        
        addCityUIState = .Search
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            
            addCityUIState = .Loading
            
            let results = await weatherRepository.SearchCities(query: trimmed)
            //guard !Task.isCancelled else { return }
            switch(results){
                case .success(let possibleCities):
//                    self.searchResults = possibleCities.map({ cities in
//                        cities.toUI()
//                    })
                addCityUIState = .Success(possibleCities.map({ cities in
                    cities.toUI()
                }))
                
                case .failure(let cityError): //Придумать как прокинуть ошибку в AddCity!
                    //self.searchResults = cityError.reserveCities
                addCityUIState = .Fail(cityError.ToUI())
            }
        }
        
        //return searchResults
    }
    
    /// Добавление города в избранное
    public func addCity(city: City) {
        guard !savedCities.contains(where: { $0.name == city.name && $0.country == city.country }) else {
            return
        }
        
        let newCity = city
        savedCities.append(newCity)
        
        Task{
            // Подгружаем сводку погоды для добавленного города
            let weather = await weatherRepository.GetWeatherForSelectedCity(for: newCity)
            switch weather{
                case .success(let currentForecast) :
                    savedCitiesWeather.append(currentForecast.ToUI(city: city))
                case .failure(let forecastError) :
                    savedCitiesWeatherError[city.name] = forecastError.ToUI()
            }
        }
    }
        
    /// Удаление города из избранного
    public func deleteCity(city: City) -> ForecastUI {
        if savedCities.count > 1 { //Должен быть хотя бы 1 сохранённый город!
            savedCities.removeAll { $0.id == city.id || ($0.name == city.name && $0.country == city.country) }
            savedCitiesWeather.removeAll { $0.city.id == city.id || ($0.city.name == city.name && $0.city.country == city.country) }
        }
        //Возвращаем п-лю рандомный сохранённый город на случай, если был удалён SelectedCity
        return savedCitiesWeather.randomElement()!
    }

    /// Проверка, добавлен ли уже город в список избранных
    public func isCitySaved(city: City) -> Bool {
        savedCities.contains(where: { $0.name == city.name && $0.country == city.country })
    }

}
