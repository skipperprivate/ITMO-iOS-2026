//
//  CityCard.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

// Карточка города для списка избранного
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

    public var body: some View {
        HStack(alignment: .center) {
            // Левая часть: название города, страна, локальное время и погодные условия
            VStack(alignment: .leading, spacing: BaseNumeral.textSpacing) {
                Text(city.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Colors.primaryText)

                Text(BaseText.Cities.countryAndTime(country: city.country, time: city.localTime))
                    .font(.caption)
                    .foregroundStyle(Colors.secondaryText)

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

                    HStack(spacing: BaseNumeral.smallSpacing) {
                        Image(systemName: symbolName)
                            .applyColors(iconColors)
                            .font(.caption)

                        Text(forecast.currentWeather.weatherCondition.description)
                            .font(.caption)
                            .foregroundStyle(Colors.secondaryText)
                    }
                    .padding(.top, BaseNumeral.textSpacing)
                } else {
                    // Значок ошибки вместо погоды
                    HStack(spacing: BaseNumeral.smallSpacing) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Colors.errorIndicator)
                            .font(.caption)

                        Text(error?.errorDescription ?? BaseText.Common.errorLoadingData)
                            .font(.caption)
                            .foregroundStyle(Colors.secondaryText)
                    }
                    .padding(.top, BaseNumeral.textSpacing)
                }
            }

            Spacer()

            // Правая часть: текущая температура или значок ошибки
            if let forecast {
                VStack(alignment: .trailing, spacing: BaseNumeral.textSpacing) {
                    Text(MetricFormatter.temperature(forecast.currentWeather.temperature, showSign: false))
                        .font(.system(size: BaseNumeral.cityCardTemperatureFontSize, weight: .light, design: .rounded))
                        .foregroundStyle(Colors.primaryText)

                    if let today = forecast.dailyWeather.first {
                        Text(BaseText.Cities.temperatureRange(
                            max: MetricFormatter.temperature(today.tempMax),
                            min: MetricFormatter.temperature(today.tempMin)
                        ))
                            .font(.caption2)
                            .foregroundStyle(Colors.secondaryText)
                    }
                }
            } else {
                VStack(alignment: .trailing, spacing: BaseNumeral.textSpacing) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: BaseNumeral.errorIconFontSize))
                        .foregroundStyle(Colors.errorIndicator)

                    Text(BaseText.Common.error)
                        .font(.caption2)
                        .foregroundStyle(Colors.secondaryText)
                }
            }
        }
        .padding(.horizontal, BaseNumeral.screenHorizontalPadding)
        .padding(.vertical, BaseNumeral.cardPadding)
        .background(Colors.cardBackgroundStrong)
        .clipShape(RoundedRectangle(cornerRadius: BaseNumeral.cardCornerRadius, style: .continuous))
    }
}
