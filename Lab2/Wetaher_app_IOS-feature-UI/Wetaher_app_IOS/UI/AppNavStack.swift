//
//  AppNavStack.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 03.10.2026.
//
import SwiftUI

public struct AppNavStack: View {
    @State private var weatherVM: WeatherMainViewModel
    @State private var cityListVM: CityListViewModel
    @State private var settingsVM: SettingsViewModel

    @State private var showCityListSheet = false
    @State private var showSettingsSheet = false

    public init(weatherRepo: WeatherRepository = WeatherRepositoryImpl()) {
        let wVM = WeatherMainViewModel(weatherRepo: weatherRepo)
        let cVM = CityListViewModel(weatherRepo: weatherRepo)
        let sVM = SettingsViewModel(weatherRepo: weatherRepo)
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
                    showSettingsSheet: $showSettingsSheet,
                    showCityListSheet: $showCityListSheet
                ) {
                    Task {
                        await weatherVM.refreshWeather()
                    }
                }
            case .Fail(let weatherErrorUI):
                WeatherError(weatherErrorUI: weatherErrorUI) {
                    Task {
                        await weatherVM.refreshWeather()
                    }
                }
            }
        }
        .sheet(isPresented: $showCityListSheet) { //Оптимизировать через enum!
            CityListView(
                savedCities: cityListVM.savedCities,
                savedCitiesWeather: cityListVM.savedCitiesWeather,
                savedCitiesWeatherError: cityListVM.savedCitiesWeatherError,
                cityListWeatherUIState: cityListVM.cityListWeatherUIState,
                searchQuery: cityListVM.searchQuery,
                searchResults: cityListVM.searchResults,
                onSelectCity: { selectedCity in
                    showCityListSheet = false
                    Task {
                        await weatherVM.selectCity(newCity: selectedCity)
                    }
                },
                onDeleteCity: { city in cityListVM.deleteCity(city: city) },
                onCityAdd: { city in
                    Task {
                        await cityListVM.addCity(city: city)
                    }
                },
                isCitySaved: { city in cityListVM.isCitySaved(city: city) },
                onRefresh: {
                    await cityListVM.loadSavedCitiesWeather()
                }
            )
            .preferredColorScheme(settingsVM.appTheme.colorScheme)
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView(settingsVM: settingsVM)
                .preferredColorScheme(settingsVM.appTheme.colorScheme)
        }
        .preferredColorScheme(settingsVM.appTheme.colorScheme)
        .onChange(of: weatherVM.weatherUIState.kind) {
            if weatherVM.weatherUIState.kind == .success {
                Task {
                    await cityListVM.loadSavedCitiesWeather()
                }
            }
        }
    }
}
