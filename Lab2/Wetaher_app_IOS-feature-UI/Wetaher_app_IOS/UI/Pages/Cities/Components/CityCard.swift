//
//  CityCard.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

/// Карточка города для списка избранного
public struct CityCard: View {
    public let city: City
    public let forecast: ForecastUI?
    public let error: WeatherErrorUI?

    public init(forecast: ForecastUI) {
        self.city = forecast.city
        self.forecast = forecast
        self.error = nil
    }

    public init(city: City, forecast: ForecastUI? = nil, error: WeatherErrorUI? = nil) {
        self.city = city
        self.forecast = forecast
        self.error = error
    }

    private var localTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let timeZone = TimeZone(identifier: city.timeZoneID) {
            formatter.timeZone = timeZone
        }
        return formatter.string(from: Date())
    }

    public var body: some View {
        HStack(alignment: .center) {
            // Левая часть: название города, страна, локальное время и погодные условия
            VStack(alignment: .leading, spacing: 3) {
                Text(city.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("\(city.country) • \(localTime)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let forecast {
                    let symbolName: String = {
                        switch forecast.currentWeather.weatherCondition.sfSymbolName {
                        case .same(let name):
                            return name
                        case .diff(let day, let night):
                            return forecast.currentWeather.isDay ? day : night
                        }
                    }()
                    let iconColors: [Color] = {
                        switch forecast.currentWeather.weatherCondition.iconColor {
                        case .same(let colors):
                            return colors
                        case .diff(let day, let night):
                            return forecast.currentWeather.isDay ? day : night
                        }
                    }()

                    HStack(spacing: 6) {
                        Image(systemName: symbolName)
                            .applyColors(iconColors)
                            .font(.caption)

                        Text(forecast.currentWeather.weatherCondition.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                } else {
                    // Значок ошибки вместо погоды
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)

                        Text(error?.errorDescription ?? "Ошибка загрузки данных")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
            }

            Spacer()

            // Правая часть: текущая температура или значок ошибки
            if let forecast {
                VStack(alignment: .trailing, spacing: 3) {
                    Text(MetricFormatter.temperature(forecast.currentWeather.temperature, showSign: false))
                        .font(.system(size: 38, weight: .light, design: .rounded))
                        .foregroundStyle(.primary)

                    if let today = forecast.dailyWeather.first {
                        Text("\(MetricFormatter.temperature(today.tempMax)) / \(MetricFormatter.temperature(today.tempMin))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.orange)

                    Text("Ошибка")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
