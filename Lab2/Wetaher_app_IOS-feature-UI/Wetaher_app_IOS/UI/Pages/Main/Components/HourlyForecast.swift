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
        VStack(alignment: .leading, spacing: 10) {
            // Заголовок
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("ПОЧАСОВОЙ ПРОГНОЗ")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Карусель часов
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(Array(hourly.enumerated()), id: \.offset) { index, item in
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

                        VStack(spacing: 8) {
                            Text(index == 0 ? "Сейчас" : WeatherUIHelper.formatTimeString(item.hour))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Image(systemName: symbolName)
                                .applyColors(iconColors)
                                .font(.body)
                                .frame(height: 22)

                            if item.precipProb > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 8))
                                    Text("\(item.precipProb)%")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundStyle(.blue)
                            } else {
                                Text(" ")
                                    .font(.system(size: 10))
                            }

                            Text(MetricFormatter.temperature(item.temperature))
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                        }
                        .frame(minWidth: 48)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
    }
}
