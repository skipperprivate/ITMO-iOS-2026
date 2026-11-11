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
        VStack(spacing: BaseNumeral.textSpacing) {
            // Город
            Text(forecastData.city.name)
                .font(.system(size: BaseNumeral.cityNameFontSize, weight: .bold, design: .default))
                .foregroundStyle(Colors.primaryText)
                .accessibilityIdentifier(AccessibilityIdentifiers.Main.cityTitle)

            // Статус погоды
            Text(forecastData.currentWeather.weatherCondition.description)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(Colors.secondaryText)
                .accessibilityIdentifier(AccessibilityIdentifiers.Main.condition)

            // Температура по шкале Цельсия
            Text(MetricFormatter.temperature(forecastData.currentWeather.temperature, showSign: false))
                .font(.system(size: BaseNumeral.currentTemperatureFontSize, weight: .thin, design: .rounded))
                .foregroundStyle(Colors.primaryText)
                .padding(.vertical, BaseNumeral.currentTemperatureVerticalPadding)
                .accessibilityIdentifier(AccessibilityIdentifiers.Main.temperature)

            // Мин - Макс и Ощущается как
            HStack(spacing: BaseNumeral.defaultSpacing) {
                if let today = todayDaily {
                    Text(BaseText.Main.maxMin(
                        max: MetricFormatter.temperature(today.tempMax),
                        min: MetricFormatter.temperature(today.tempMin)
                    ))
                        .font(.subheadline)
                        .foregroundStyle(Colors.secondaryText)

                    Text(BaseText.Main.currentWeatherSeparator)
                        .foregroundStyle(Colors.tertiaryText)
                }

                Text(BaseText.Main.feelsLike(
                    MetricFormatter.temperature(forecastData.currentWeather.apparentTemp)
                ))
                    .font(.subheadline)
                    .foregroundStyle(Colors.secondaryText)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Main.feelsLike)
            }
            .padding(.top, BaseNumeral.textSpacing)
        }
        .padding(.vertical, BaseNumeral.cardPadding)
    }
}
