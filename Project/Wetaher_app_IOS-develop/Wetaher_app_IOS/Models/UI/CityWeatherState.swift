//
//  CityWeather.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 20.10.2026.
//

public enum CityWeatherState: Equatable, Hashable {
    case CityWithWeather(ForecastUI)
    case NewCity(City)
}
