//
//  WeatherRepositoryImpl.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//
import Foundation

public class WeatherRepositoryImpl: WeatherRepository{
    private var currentForecast: ForecastUI
    
    public init(currentWeather: ForecastUI = .moskowWeather) {
        self.currentForecast = currentWeather
    }
    
    public func GetWeatherForSelectedCity(for city: City) async -> Result<ForecastUI, WeatherErrorUI>{
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        currentForecast =
            switch city{
                case .moscow : .moskowWeather
                case .saintPetersburg : .saintPetersburgWeather
                case .kazan : .kazanWeather
                case .krasnoyarsk : .krasnoyarskWeather
                case .nizhnyNovgorod : .nizhnyNovgorodWeather
                case .novosibirsk : .novosibirskWeather
                case .kaliningrad : .kaliningradWeather
                case .samara : .samaraWeather
                case .vladivostok : .vladivostokWeather
                case .yekaterinburg : .yekaterinburgWeather
                case .malmo : .malmoWeather
                case .hong_Kong : .hongKongWeather
                default : .moskowWeather
            }
        
        if Int.random(in: 1...10) % 2 == 0{
            return .success(currentForecast)
        }
        else{
            return .failure(WeatherErrorUI(errorCode: 67 , errorDescription: "Trial error exception"))
        }
        
    }
    
    public func LoadFavoriteCities() -> [City] {
        return City.defaultFavorites
    }
    
    public func SearchCities(query: String) async -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty { return [] }

        return City.avaliableCities.filter { city in
            city.name.lowercased().contains(trimmed) ||
            city.country.lowercased().contains(trimmed)
        }
    }
}
