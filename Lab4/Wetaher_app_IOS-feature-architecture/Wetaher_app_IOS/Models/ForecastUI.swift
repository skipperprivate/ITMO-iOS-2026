//
//  WeatherUI.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 03.10.2026.
//
import Foundation

public struct ForecastUI : Equatable, Hashable{
    let city: City
    let currentWeather: CurrentWeather
    let hourlyWeather: [HourlyWeather]
    let dailyWeather: [DailyWeather]
}
