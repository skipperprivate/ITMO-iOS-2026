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
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("ПРОГНОЗ НА 7 ДНЕЙ")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // Список дней
            VStack(spacing: 10) {
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
                        VStack(alignment: .leading, spacing: 2) {
                            Text(index == 0 ? "Сегодня" : item.day)
                                .font(.body)
                                .fontWeight(index == 0 ? .semibold : .medium)
                                .foregroundStyle(.primary)

                            Text(WeatherUIHelper.formatDateString(item.date))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 85, alignment: .leading)

                        Spacer()

                        // Иконка погоды и вероятность осадков
                        HStack(spacing: 6) {
                            Image(systemName: symbolName)
                                .applyColors(iconColors)
                                .font(.title3)

                            if item.precipProbabilityMean > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 8))
                                    Text("\(item.precipProbabilityMean)%")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundStyle(.blue)
                            }
                        }
                        .frame(minWidth: 60, alignment: .center)

                        Spacer()

                        // Температуры: максимум и минимум
                        HStack(spacing: 12) {
                            Text(MetricFormatter.temperature(item.tempMax))
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundStyle(.primary)
                                .frame(width: 44, alignment: .trailing)

                            Text(MetricFormatter.temperature(item.tempMin))
                                .font(.system(.body, design: .rounded, weight: .regular))
                                .foregroundStyle(.secondary)
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, 2)

                    if index < daily.count - 1 {
                        Divider()
                            .opacity(0.4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
    }
}
