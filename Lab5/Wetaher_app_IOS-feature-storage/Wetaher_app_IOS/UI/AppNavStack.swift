//
//  AppNavStack.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 03.10.2026.
//
import SwiftUI

public struct AppNavStack: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var weatherVM: WeatherMainViewModel
    @State private var cityListVM: CityListViewModel
    @State private var settingsVM: SettingsViewModel

    @State private var showCityListSheet = false
    @State private var showSettingsSheet = false

    @State private var currentColorScheme: ColorScheme?

    @MainActor
    public init(
        weatherRepo: WeatherRepository? = nil,
        preferences: UserPreferencesStoring? = nil
    ) {
        let weatherRepo = weatherRepo ?? WeatherRepositoryImpl()
        let preferences = preferences ?? UserPreferencesStore()

        let wVM = WeatherMainViewModel(weatherRepo: weatherRepo, preferences: preferences)
        let cVM = CityListViewModel(weatherRepo: weatherRepo, preferences: preferences)
        let sVM = SettingsViewModel(preferences: preferences)
        _weatherVM = State(initialValue: wVM)
        _cityListVM = State(initialValue: cVM)
        _settingsVM = State(initialValue: sVM)
        _currentColorScheme = State(initialValue: sVM.appTheme.colorScheme)
    }

    public var body: some View {
        ZStack {
            if case .Success(let weatherUI) = weatherVM.weatherUIState {
                WeatherBackground(
                    condition: weatherUI.currentWeather.weatherCondition,
                    isDay: weatherUI.currentWeather.isDay
                )
            } else {
                WeatherBackground()
            }

            switch weatherVM.weatherUIState {
                case .Loading:
                    ProgressView()
                case .Success(let weatherUI):
                    WeatherSuccess(
                        currentForecast: weatherUI,
                        isFromCache: weatherVM.isFromCache,
                        cacheAgeDescription: weatherVM.cacheAgeDescription,
                        showSettingsSheet: $showSettingsSheet,
                        showCityListSheet: $showCityListSheet
                    ) {
                        weatherVM.refreshWeather()
                    }
                case .Fail(let weatherErrorUI):
                    WeatherError(weatherErrorUI: weatherErrorUI) {
                        weatherVM.refreshWeather()
                    }
            }
        }
        .sheet(isPresented: $showCityListSheet) { //Оптимизировать через enum!
            CityListView(
                savedCities: cityListVM.savedCities,
                savedCitiesWeather: cityListVM.savedCitiesWeather,
                savedCitiesWeatherError: cityListVM.savedCitiesWeatherError,
                cityListWeatherUIState: cityListVM.cityListWeatherUIState,
                addCityUiState: cityListVM.addCityUIState,
                //searchQuery: cityListVM.searchQuery,
                //searchResults: cityListVM.searchResults,
                onSelectCity: { selectedCity in
                    showCityListSheet = false
                    weatherVM.selectCity(newCity: selectedCity)
                },
                onDeleteCity: { city in
                    guard let potenialNewSelectedCity = cityListVM.deleteCity(city: city) else { return }
                    if city.id == weatherVM.selectedCity.id{ //Если был удалён SelectedCity, то меняем его на рандомный сохранённый
                        weatherVM.selectCity(newCity: .CityWithWeather(potenialNewSelectedCity))
                    }
                     },
                onCityAdd: { city in
                    cityListVM.addCity(city: city)
                },
                isCitySaved: { city in cityListVM.isCitySaved(city: city) },
                onRefresh: {
                    if case .Success(let weatherUI) = weatherVM.weatherUIState {
                        cityListVM.loadSavedCitiesWeather(selectedCityForecast: weatherUI)
                    }
                },
                onSearch: { query in
                    cityListVM.searchCities(query: query)
                    
                }
            )
            .preferredColorScheme(currentColorScheme)
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView(settingsVM: settingsVM) { theme in
                settingsVM.selectTheme(theme)
                currentColorScheme = theme.colorScheme
            }
            .preferredColorScheme(currentColorScheme)
        }
        .preferredColorScheme(currentColorScheme)
        .onChange(of: weatherVM.weatherUIState.kind) {
            if weatherVM.weatherUIState.kind == .success && !weatherVM.isCascadeUpdateForbidden{
                if case .Success(let weatherUI) = weatherVM.weatherUIState {
                    cityListVM.loadSavedCitiesWeather(selectedCityForecast: weatherUI)
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            //Перед уходом в фон обновляем кэш, чтобы офлайн-режим показывал максимально свежие данные.
            if newPhase == .background {
                weatherVM.prepareForOffline()
            }
        }
    }
}
