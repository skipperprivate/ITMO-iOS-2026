//
//  CurrentWeatherHeader.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//
import SwiftUI

struct CurrentWeatherHeader: View {
    public let forecastData: ForecastUI
    
    public init(forecastData: ForecastUI) {
        self.forecastData = forecastData
    }
    
    var body: some View {
        Text("Данные загружены")
        Text(forecastData.city.name)
        Text(forecastData.currentWeather.dateTime)
        Text("\(forecastData.currentWeather.temperature)")
        Text(forecastData.dailyWeather[0].sunrise)
        Text(forecastData.hourlyWeather[1].weatherCondition.description)
    }
}
