//
//  AppNavStack.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 03.10.2026.
//
import SwiftUI

public struct AppNavStack: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var environmentColorScheme

    @State private var weatherVM: WeatherMainViewModel
    @State private var cityListVM: CityListViewModel
    @State private var settingsVM: SettingsViewModel

    @State private var showCityListSheet = false
    @State private var showSettingsSheet = false

    // Цветовая тема приложения
    private var appColorScheme: ColorScheme? {
        settingsVM.appTheme.colorScheme
    }
    private var presentedColorScheme: ColorScheme {
        appColorScheme ?? environmentColorScheme
    }

    @MainActor
    public init(
        weatherRepo: WeatherRepository? = nil,
        cityRepo: CityRepository? = nil,
        settingsRepo: SettingsRepository? = nil
    ) {
        let weatherRepo = WeatherRepositoryImpl()
        let cityRepo = CityRepositoryImpl()
        let settingsRepo = SettingsRepositoryImpl()

        let wVM = WeatherMainViewModel(weatherRepo: weatherRepo, cityRepo: cityRepo)
        let cVM = CityListViewModel(weatherRepo: weatherRepo, cityRepo: cityRepo)
        let sVM = SettingsViewModel(settingsRepo: settingsRepo)
        _weatherVM = State(initialValue: wVM)
        _cityListVM = State(initialValue: cVM)
        _settingsVM = State(initialValue: sVM)
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
                    isFromCache: weatherVM.isFromCache, //Мог бы быть cache через enum
                    cacheAgeDescription: weatherVM.cacheAgeDescription,
                    showSettingsSheet: $showSettingsSheet,
                    showCityListSheet: $showCityListSheet
                ) {
                    weatherVM.refeshWeatherWrapper()
                }
            case .Fail(let weatherErrorUI):
                WeatherError(weatherErrorUI: weatherErrorUI) {
                    weatherVM.refeshWeatherWrapper()
                }
            }
        }
        .sheet(isPresented: $showCityListSheet) {
            CityListView(
                savedCities: cityListVM.savedCities,
                savedCitiesWeather: cityListVM.savedCitiesWeather,
                savedCitiesWeatherError: cityListVM.savedCitiesWeatherError,
                cityListWeatherUIState: cityListVM.cityListWeatherUIState,
                addCityUiState: cityListVM.addCityUIState,
                onSelectCity: { selectedCity in
                    showCityListSheet = false
                    weatherVM.selectCityWrapper(newCity: selectedCity)
                },
                onDeleteCity: { city in
                    guard let potenialNewSelectedCity = cityListVM.deleteCity(city: city) else { return }
                    if city.id == weatherVM.selectedCity.id{ //Если был удалён SelectedCity, то меняем его на рандомный сохранённый
                        weatherVM.selectCityWrapper(newCity: .CityWithWeather(potenialNewSelectedCity))
                    }
                },
                onCityAdd: { city in
                    cityListVM.addCityWrapper(city: city)
                },
                isCitySaved: { city in cityListVM.isCitySaved(city: city) },
                onRefresh: {
                    if case .Success(let weatherUI) = weatherVM.weatherUIState {
                        cityListVM.loadSavedCitiesWeatherWrapper(selectedCityForecast: weatherUI)
                    }
                },
                onSearch: { query in
                    cityListVM.searchCities(query: query)

                }
            )
            .preferredColorScheme(presentedColorScheme)
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView(appTheme: settingsVM.themeSelection)
                .preferredColorScheme(presentedColorScheme)
        }
        .preferredColorScheme(appColorScheme)
        .onChange(of: weatherVM.weatherUIState.kind) {
            if weatherVM.weatherUIState.kind == .success && !weatherVM.isCascadeUpdateForbidden {
                if case .Success(let weatherUI) = weatherVM.weatherUIState {
                    cityListVM.loadSavedCitiesWeatherWrapper(selectedCityForecast: weatherUI)
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Перед уходом в фон обновляем кэш, чтобы офлайн-режим показывал максимально свежие данные
            if newPhase == .background {
                weatherVM.prepareForOffline()
            }
        }
    }
}
