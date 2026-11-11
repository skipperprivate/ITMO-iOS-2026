//
//  DailyForecast.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

/// Прогноз на неделю
public struct DailyForecast: View {
    public let daily: [DailyWeather]

    public init(daily: [DailyWeather] = []) {
        self.daily = daily
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: BaseNumeral.defaultSpacing) {
            // Заголовок
            HStack(spacing: BaseNumeral.smallSpacing) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(Colors.secondaryText)
                Text(BaseText.Main.dailyTitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Colors.secondaryText)
            }
            .padding(.horizontal, BaseNumeral.screenHorizontalPadding)
            .padding(.top, BaseNumeral.cardPadding)

            // Список дней
            VStack(spacing: BaseNumeral.smallSpacing) {
                ForEach(Array(daily.enumerated()), id: \.offset) { index, item in
                    let symbolName: String = {
                        switch item.weatherCondition.sfSymbolName {
                        case .same(let name):
                            return name
                        case .diff(let day, _):
                            return day
                        }
                    }()
                    let iconColors: [Color] = {
                        switch item.weatherCondition.iconColor {
                        case .same(let colors):
                            return colors
                        case .diff(let day, _):
                            return day
                        }
                    }()

                    HStack(alignment: .center) {
                        // День недели и дата
                        VStack(alignment: .leading, spacing: BaseNumeral.textSpacing) {
                            Text(item.day)
                                .font(.body)
                                .fontWeight(index == 0 ? .semibold : .medium)
                                .foregroundStyle(Colors.primaryText)

                            Text(item.date)
                                .font(.caption2)
                                .foregroundStyle(Colors.secondaryText)
                        }
                        .frame(width: BaseNumeral.columnWidth, alignment: .leading)

                        Spacer()

                        // Иконка погоды и вероятность осадков
                        HStack(spacing: BaseNumeral.smallSpacing) {
                            Image(systemName: symbolName)
                                .applyColors(iconColors)
                                .font(.title3)

                            if item.precipProbabilityMean > 0 {
                                HStack(spacing: BaseNumeral.textSpacing) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: BaseNumeral.precipitationIconFontSize))
                                    Text(BaseText.Metrics.percent(item.precipProbabilityMean))
                                        .font(.system(size: BaseNumeral.captionFontSize, weight: .semibold))
                                }
                                .foregroundStyle(Colors.precipitation)
                            }
                        }
                        .frame(minWidth: BaseNumeral.controlSize, alignment: .center)

                        Spacer()

                        // Температуры: максимум и минимум
                        HStack(spacing: BaseNumeral.defaultSpacing) {
                            Text(MetricFormatter.temperature(item.tempMax))
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundStyle(Colors.primaryText)
                                .frame(width: BaseNumeral.columnWidth, alignment: .trailing)

                            Text(MetricFormatter.temperature(item.tempMin))
                                .font(.system(.body, design: .rounded, weight: .regular))
                                .foregroundStyle(Colors.secondaryText)
                                .frame(width: BaseNumeral.columnWidth, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, BaseNumeral.textSpacing)

                    if index < daily.count - 1 {
                        Divider()
                            .opacity(BaseNumeral.dividerOpacity)
                    }
                }
            }
            .padding(.horizontal, BaseNumeral.screenHorizontalPadding)
            .padding(.bottom, BaseNumeral.cardPadding)
        }
        .background(Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: BaseNumeral.largeCardCornerRadius, style: .continuous))
        .padding(.horizontal, BaseNumeral.screenHorizontalPadding)
    }
}
