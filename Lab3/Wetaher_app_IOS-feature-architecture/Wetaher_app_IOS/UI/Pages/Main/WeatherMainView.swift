import SwiftUI
import Playgrounds

struct WeatherMainView: View {
    
    var currentForecast: ForecastUI
    let onPullToRefresh: () -> Void
    
    private let columns = [ //Мб это можно сделать получше?
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public init(currentForecast: ForecastUI, onPullToRefresh: @escaping () -> Void) {
        self.currentForecast = currentForecast
        self.onPullToRefresh = onPullToRefresh
    }
    
    var body: some View {
        
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
                //let timeZone = TimeZone(identifier: weather.city.timeZoneIdentifier) ?? .current
                HourlyForecast()

                // Прогноз на 7 дней
                DailyForecast()

                // Сетка метрик в системе СИ
                LazyVGrid(columns: columns, spacing: 12) {
                    WindMetricCard()

                    PressureMetricCard()

                    HumidityMetricCard()

                    UVMetricCard()

                    SunTimesMetricCard()

                    VisibilityMetricCard()
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
