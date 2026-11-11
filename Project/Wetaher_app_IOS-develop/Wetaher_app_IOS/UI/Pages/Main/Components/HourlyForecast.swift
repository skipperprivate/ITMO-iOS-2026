//
//  HourlyForecast.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

/// Почасовой прогноз погоды
public struct HourlyForecast: View {
    public let hourly: [HourlyWeather]
    public let timeZone: TimeZone

    public init(hourly: [HourlyWeather] = [], timeZone: TimeZone = .current) {
        self.hourly = hourly
        self.timeZone = timeZone
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: BaseNumeral.smallSpacing) {
            // Заголовок
            HStack(spacing: BaseNumeral.smallSpacing) {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundStyle(Colors.secondaryText)
                Text(BaseText.Main.hourlyTitle)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Colors.secondaryText)
            }
            .padding(.horizontal, BaseNumeral.screenHorizontalPadding)
            .padding(.top, BaseNumeral.cardPadding)

            // Карусель часов
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BaseNumeral.wideSpacing) {
                    ForEach(Array(hourly.enumerated()), id: \.offset) { _, item in
                        let symbolName: String = {
                            switch item.weatherCondition.sfSymbolName {
                            case .same(let name):
                                return name
                            case .diff(let day, let night):
                                return item.isDay ? day : night
                            }
                        }()
                        let iconColors: [Color] = {
                            switch item.weatherCondition.iconColor {
                            case .same(let colors):
                                return colors
                            case .diff(let day, let night):
                                return item.isDay ? day : night
                            }
                        }()

                        VStack(spacing: BaseNumeral.smallSpacing) {
                            Text(item.hour)
                                .font(.caption)
                                .foregroundStyle(Colors.secondaryText)

                            Image(systemName: symbolName)
                                .applyColors(iconColors)
                                .font(.body)
                                .frame(height: BaseNumeral.iconHeight)

                            if item.precipProb > 0 {
                                HStack(spacing: BaseNumeral.textSpacing) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: BaseNumeral.precipitationIconFontSize))
                                    Text(BaseText.Metrics.percent(item.precipProb))
                                        .font(.system(size: BaseNumeral.captionFontSize, weight: .bold))
                                }
                                .foregroundStyle(Colors.precipitation)
                            } else {
                                Text(BaseText.Main.hourlyPlaceholder)
                                    .font(.system(size: BaseNumeral.captionFontSize))
                            }

                            Text(MetricFormatter.temperature(item.temperature))
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundStyle(Colors.primaryText)
                        }
                        .frame(minWidth: BaseNumeral.controlSize)
                    }
                }
                .padding(.horizontal, BaseNumeral.screenHorizontalPadding)
                .padding(.bottom, BaseNumeral.cardPadding)
            }
        }
        .background(Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: BaseNumeral.cardCornerRadius, style: .continuous))
        .padding(.horizontal, BaseNumeral.screenHorizontalPadding)
    }
}
