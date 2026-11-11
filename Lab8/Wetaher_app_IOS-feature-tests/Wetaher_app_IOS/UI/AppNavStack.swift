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

    @State private var currentColorScheme: ColorScheme?

    public init(weatherRepo: WeatherRepository = WeatherRepositoryImpl()) {
        let wVM = WeatherMainViewModel(weatherRepo: weatherRepo)
        let cVM = CityListViewModel(weatherRepo: weatherRepo)
        let sVM = SettingsViewModel(weatherRepo: weatherRepo)
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
        .sheet(isPresented: $showCityListSheet) { // Оптимизировать через enum!
            CityListView(
                savedCities: cityListVM.savedCities,
                savedCitiesWeather: cityListVM.savedCitiesWeather,
                savedCitiesWeatherError: cityListVM.savedCitiesWeatherError,
                cityListWeatherUIState: cityListVM.cityListWeatherUIState,
                addCityUiState: cityListVM.addCityUIState,
                // searchQuery: cityListVM.searchQuery,
                // searchResults: cityListVM.searchResults,
                onSelectCity: { selectedCity in
                    showCityListSheet = false
                    weatherVM.selectCityWrapper(newCity: selectedCity)
                },
                onDeleteCity: { city in
                    let potenialNewSelectedCity = cityListVM.deleteCity(city: city)
                    if city.id == weatherVM.selectedCity.id { // Если был удалён SelectedCity, то меняем его на рандомный сохранённый
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
            .preferredColorScheme(currentColorScheme)
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView(currentColorScheme: currentColorScheme) { theme in
                settingsVM.appTheme = theme
                currentColorScheme = theme.colorScheme
            }
            .preferredColorScheme(currentColorScheme)
        }
        .preferredColorScheme(currentColorScheme)
        .onChange(of: weatherVM.weatherUIState.kind) {
            if weatherVM.weatherUIState.kind == .success && !weatherVM.isCascadeUpdateForbidden {
                if case .Success(let weatherUI) = weatherVM.weatherUIState {
                    cityListVM.loadSavedCitiesWeatherWrapper(selectedCityForecast: weatherUI)
                }
            }
        }
    }
}
