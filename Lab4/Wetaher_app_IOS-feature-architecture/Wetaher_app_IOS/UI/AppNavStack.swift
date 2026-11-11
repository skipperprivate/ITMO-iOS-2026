//
//  AppNavStack.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 03.10.2026.
//
import SwiftUI

struct AppNavStack: View{
    
    @State private var weatherVM: WeatherMainViewModel
    @State private var cityListVM : CityListViewModel
    @State private var settingsVM : SettingsViewModel
    
    @State private var showCityListSheet = false
    @State private var showSettingsSheet = false
    
    @State private var currentColorScheme: ColorScheme?
    
    public init (weatherRepo: WeatherRepository = WeatherRepositoryImpl()) {
        weatherVM = WeatherMainViewModel(weatherRepo: weatherRepo)
        cityListVM = CityListViewModel(weatherRepo: weatherRepo)
        settingsVM = SettingsViewModel(weatherRepo: weatherRepo)
        currentColorScheme = settingsVM.appTheme.colorScheme //Не знаю будет ли он так корректно меняться
    }
    
    var body: some View{
        ZStack{
            WeatherBackground()
            
            switch weatherVM.weatherUIState {
                case .Loading:
                    ProgressView()
                case .Success(let weatherUI):
                    WeatherSuccess(
                        currentForecast: weatherUI,
                        showSettingsSheet: $showSettingsSheet,
                        showCityListSheet: $showCityListSheet
                    ){
                        Task{
                            await weatherVM.refreshWeather()
                        }
                    }
                case .Fail(let weatherErrorUI):
                WeatherError(weatherErrorUI: weatherErrorUI){
                    Task{
                        await weatherVM.refreshWeather()
                    }
                }
                .preferredColorScheme(currentColorScheme) //settingsVM.appTheme.colorScheme
                
            }
        }
        .sheet(isPresented: $showCityListSheet) { //Оптимизировать через enum!
            CityListView(savedCitiesWeather: cityListVM.savedCitiesWeather, savedCitiesWeatherError: cityListVM.savedCitiesWeatherError, cityListWeatherUIState: cityListVM.cityListWeatherUIState,
            searchQuery: cityListVM.searchQuery, searchResults: cityListVM.searchResults,
            onSelectCity: { selectedCity in
                showCityListSheet = false
                Task {
                    await weatherVM.selectCity(newCity: selectedCity)
                }
            },
            onDeleteCity: {index in cityListVM.deleteCity(at: index)},
            onCityAdd: {city in
                Task{
                    await cityListVM.addCity(city: city)
                }},
            isCitySaved: {city in cityListVM.isCitySaved(city: city)})
            .preferredColorScheme(currentColorScheme)
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView(currentColorScheme: currentColorScheme){ theme in
                settingsVM.appTheme = theme
            }
            .preferredColorScheme(currentColorScheme)
        }
        .preferredColorScheme(currentColorScheme)
        .onChange(of: weatherVM.weatherUIState.kind) {
            if weatherVM.weatherUIState.kind == .success{
                Task{
                    await cityListVM.loadSavedCitiesWeather()
                }
            }
        }
    }
}
