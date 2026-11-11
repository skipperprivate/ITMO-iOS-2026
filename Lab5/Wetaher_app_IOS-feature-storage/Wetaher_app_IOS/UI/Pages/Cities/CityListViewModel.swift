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
public class CityListViewModel {
    /// Избранные города храним как сущности, а в UI отдаём готовую проекцию.
    private var savedCityEntities: [CityEntity] = []
    public var savedCities: [City] {
        savedCityEntities.map { $0.toUI() }
    }
    public var savedCitiesWeather: [ForecastUI] = []
    public var savedCitiesWeatherError: [String: WeatherErrorUI] = [:]

//    public var searchQuery: String = "" {
//        didSet {
//            searchCities()
//        }
//    }
    //public var searchResults: [City] = []
    private var searchTask: Task<Void, Never>?
    /// Последние результаты поиска в виде сущностей: из них берём город при добавлении.
    private var searchResults: [CityEntity] = []

    public var cityListWeatherUIState: CityListUIState
    public var addCityUIState: AddCityUIState

    private let weatherRepository: WeatherRepository
    private let preferences: UserPreferencesStoring

    public init(weatherRepo: WeatherRepository, preferences: UserPreferencesStoring) {
        self.weatherRepository = weatherRepo
        self.preferences = preferences

        let storedCities = preferences.favoriteCities
        if storedCities.isEmpty {
            // Первый запуск: приложение не должно остаться без избранных городов.
            self.savedCityEntities = CityEntity.defaultFavorites
            preferences.favoriteCities = CityEntity.defaultFavorites
        } else {
            self.savedCityEntities = storedCities
        }

        cityListWeatherUIState = .Loading
        addCityUIState = .Loading
    }

    public func loadSavedCitiesWeather(selectedCityForecast: ForecastUI) {
        let selectedCity = selectedCityForecast.city

        var updatedList: [ForecastUI] = []
        savedCitiesWeatherError = [:]

        Task {
            for city in savedCities { //Cюда прокидывается selectedCity, чтобы лишний раз не запрашивать уже запрошенный город
                if city.id == selectedCity.id {
                    updatedList.append(selectedCityForecast)
                } else {
                    let weather = await weatherRepository.GetWeatherForSelectedCity(for: city)

                    switch weather {
                    case .success(let snapshot):
                        updatedList.append(snapshot.entity.toUI())
                    case .failure(let forecastError):
                        savedCitiesWeatherError[city.name] = forecastError.toEntity().ToUI()
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
            return
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
                let entities = possibleCities.map { $0.toEntity() }
                searchResults = entities
                addCityUIState = .Success(entities.map { $0.toUI() })

            case .failure(let cityError): //Ошибка поиска прокидывается в AddCityView
                    //self.searchResults = cityError.reserveCities
                addCityUIState = .Fail(cityError.ToUI())
            }
        }

        //return searchResults
    }

    /// Добавление города в избранное
    public func addCity(city: City) {
        guard !isCitySaved(city: city) else { return }
        guard let entity = cityEntity(for: city) else { return }

        savedCityEntities.append(entity)
        preferences.favoriteCities = savedCityEntities

        Task {
            // Подгружаем сводку погоды для добавленного города
            let weather = await weatherRepository.GetWeatherForSelectedCity(for: city)
            switch weather {
            case .success(let snapshot):
                savedCitiesWeather.append(snapshot.entity.toUI())
            case .failure(let forecastError):
                savedCitiesWeatherError[city.name] = forecastError.toEntity().ToUI()
            }
        }
    }

    /// Удаление города из избранного
    public func deleteCity(city: City) -> ForecastUI? {
        if savedCityEntities.count > 1 { //Должен быть хотя бы 1 сохранённый город!
            savedCityEntities.removeAll { $0.id == city.id || ($0.name == city.name && $0.country == city.country) }
            savedCitiesWeather.removeAll { $0.city.id == city.id || ($0.city.name == city.name && $0.city.country == city.country) }
            savedCitiesWeatherError.removeValue(forKey: city.name)
            preferences.favoriteCities = savedCityEntities
        }
        //Возвращаем п-лю рандомный сохранённый город на случай, если был удалён SelectedCity
        return savedCitiesWeather.randomElement()
    }

    /// Ищет сущность города среди последних результатов поиска или встроенного списка.
    private func cityEntity(for city: City) -> CityEntity? {
        searchResults.first { $0.id == city.id } ??
            CityEntity.avaliableCities.first { $0.id == city.id }
    }

    /// Проверка, добавлен ли уже город в список избранных
    public func isCitySaved(city: City) -> Bool {
        savedCityEntities.contains(where: { $0.name == city.name && $0.country == city.country })
    }

}
