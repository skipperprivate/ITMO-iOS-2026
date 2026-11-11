import SwiftUI

/// Главный экран погоды: заголовок, почасовой прогноз, 7-дневный прогноз и сетка метеорологических метрик
public struct WeatherMainView: View {
    public var currentForecast: ForecastUI
    public let onPullToRefresh: () -> Void

    private let columns = [ //Мб это можно сделать получше?
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public init(currentForecast: ForecastUI, onPullToRefresh: @escaping () -> Void) {
        self.currentForecast = currentForecast
        self.onPullToRefresh = onPullToRefresh
    }

    public var body: some View {
        let current = currentForecast.currentWeather
        let timeZone = TimeZone(identifier: currentForecast.city.timeZoneID) ?? .current
        let todayDaily = currentForecast.dailyWeather.first

        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                

                // Индикатор офлайн-режима с давностью обновления кэша
//                if weatherVM.isFromCache {
//                    HStack(spacing: 6) {
//                        Image(systemName: "wifi.slash")
//                            .font(.caption2)
//
//                        if let age = weatherVM.cacheAgeDescription {
//                            Text("Офлайн • Обновлено \(age)")
//                                .font(.caption2)
//                                .fontWeight(.medium)
//                        } else {
//                            Text("Офлайн-режим (сохраненные данные)")
//                                .font(.caption2)
//                                .fontWeight(.medium)
//                        }
//                    }
//                    .foregroundStyle(.secondary)
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 4)
//                    .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
//                    .clipShape(Capsule())
//                    .padding(.top, 0)
//                }

                // Главный заголовок
                CurrentWeatherHeader(forecastData: currentForecast)

                // Почасовой прогноз
                //let timeZone = TimeZone(identifier: currentForecast.city.timeZoneID) ?? .current
                HourlyForecast(
                    hourly: currentForecast.hourlyWeather,
                    timeZone: timeZone
                )

                // Прогноз на 7 дней
                DailyForecast(
                    daily: currentForecast.dailyWeather
                )

                // Сетка метрик в системе
                LazyVGrid(columns: columns, spacing: 12) {
                    WindMetricCard(
                        speedMps: current.windSpeed,
                        directionDegrees: current.windDirection,
                        gustMps: current.windGusts
                    )

                    PressureMetricCard(
                        pressureHpa: current.pressure
                    )

                    HumidityMetricCard(
                        humidity: current.relativeHumidity,
                        dewPoint: current.dewPoint
                    )

                    UVMetricCard(
                        uvIndex: todayDaily?.uVIndex ?? 0.0
                    )

                    SunTimesMetricCard(
                        sunrise: todayDaily?.sunrise ?? "",
                        sunset: todayDaily?.sunset ?? ""
                    )

                    VisibilityMetricCard(
                        visibilityMeters: current.visibility
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .refreshable {//Прокинуть это как событие в НавСтак!
            onPullToRefresh()
        }
    }
}
