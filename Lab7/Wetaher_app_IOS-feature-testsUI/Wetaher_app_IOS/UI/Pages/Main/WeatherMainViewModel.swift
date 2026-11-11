//
//  WeatherMainViewModel.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//
import Observation

@MainActor
@Observable
public class WeatherMainViewModel{
    private let weatherRepository: WeatherRepository
    
    public var selectedCity: City
    public var weatherUIState: WeatherUIState
    public var isLoadingStarted: Bool = false
    public var isCascadeUpdateForbidden = false
    
    public init(weatherRepo: WeatherRepository, initalValue: City = .moscow){
        weatherRepository = weatherRepo
        selectedCity = initalValue
        weatherUIState = .Loading
        
        Task{
            await loadWeather()
        }
        
    }
    
    private func loadWeather(addNewCity: Bool = false) {
        
        guard !isLoadingStarted else { return }
        isCascadeUpdateForbidden =
            if(addNewCity){
                true
            }else{
                false
            }
        
        isLoadingStarted = true
        Task{
            
            let weather = await weatherRepository.GetWeatherForSelectedCity(for: selectedCity)
            
            switch weather{
                case .success(let currentForecast) :
                weatherUIState = .Success(currentForecast.ToUI(city: selectedCity)) //Нужен ли здесь City?
                case .failure(let forecastError) :
                weatherUIState = .Fail(forecastError.ToUI())
            }
            
            isLoadingStarted = false
        }
            
    }
    
    public func refreshWeather(){
        weatherUIState = .Loading
        
        loadWeather()
    }
    
    public func selectCity(newCity: CityWeatherState){
        var city: City
        switch(newCity){
        case .CityWithWeather(let cityWeather):
            city = cityWeather.city
            guard city.id != selectedCity.id else { return } //Не очень понимаю как правильно читать guard
            self.selectedCity = city
            weatherUIState = .Success(cityWeather)
            
        case .NewCity(let addedCity):
            city = addedCity
            guard city.id != selectedCity.id else { return }
            self.selectedCity = city
            
            weatherUIState = .Loading
            loadWeather(addNewCity: true)
        }
    }
    
}
