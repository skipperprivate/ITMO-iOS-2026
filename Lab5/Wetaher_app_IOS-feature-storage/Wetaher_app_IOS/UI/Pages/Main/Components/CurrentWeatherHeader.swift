//
//  CurrentWeatherHeader.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//
import SwiftUI

/// Заголовок текущей погоды
public struct CurrentWeatherHeader: View {
    public let forecastData: ForecastUI

    public init(forecastData: ForecastUI) {
        self.forecastData = forecastData
    }

    private var todayDaily: DailyWeather? {
        forecastData.dailyWeather.first
    }

    public var body: some View {
        VStack(spacing: 4) {
            // Город
            Text(forecastData.city.name)
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundStyle(.primary)

            // Статус погоды
            Text(forecastData.currentWeather.weatherCondition.description)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            // Температура по шкале Цельсия
            Text(MetricFormatter.temperature(forecastData.currentWeather.temperature, showSign: false))
                .font(.system(size: 84, weight: .thin, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.vertical, -8)

            // Мин / Макс и Ощущается как
            HStack(spacing: 12) {
                if let today = todayDaily {
                    Text("Макс: \(MetricFormatter.temperature(today.tempMax)), мин: \(MetricFormatter.temperature(today.tempMin))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .foregroundStyle(.tertiary)
                }

                Text("Ощущается как \(MetricFormatter.temperature(forecastData.currentWeather.apparentTemp))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 12)
    }
}
