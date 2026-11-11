//
//  WeatherUI.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 03.10.2026.
//
import Foundation

public struct ForecastUI: Equatable, Hashable {
    public let city: City
    public let currentWeather: CurrentWeather
    public let hourlyWeather: [HourlyWeather]
    public let dailyWeather: [DailyWeather]
}
