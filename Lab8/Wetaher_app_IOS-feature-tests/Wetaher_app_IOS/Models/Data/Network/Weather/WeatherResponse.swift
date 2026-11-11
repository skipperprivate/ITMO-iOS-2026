//
//  WeatherResponse.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 15.10.2026.
//

public struct WeatherResponse: Codable {

    public let latitude: Double
    public let longitude: Double

    public let current: CurrentWeatherResponse
    public let hourly: HourlyWeatherResponse
    public let daily: DailyWeatherResponse
}
