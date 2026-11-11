import SwiftUI

// Главный экран погоды: заголовок, почасовой прогноз, 7-дневный прогноз и сетка метеорологических метрик
public struct WeatherMainView: View {
    public var currentForecast: ForecastUI
    public var isFromCache: Bool
    public var cacheAgeDescription: String?
    public let onPullToRefresh: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: BaseNumeral.defaultSpacing),
        GridItem(.flexible(), spacing: BaseNumeral.defaultSpacing)
    ]

    public init(
        currentForecast: ForecastUI,
        isFromCache: Bool = false,
        cacheAgeDescription: String? = nil,
        onPullToRefresh: @escaping () -> Void
    ) {
        self.currentForecast = currentForecast
        self.isFromCache = isFromCache
        self.cacheAgeDescription = cacheAgeDescription
        self.onPullToRefresh = onPullToRefresh
    }

    public var body: some View {
        let current = currentForecast.currentWeather
        let timeZone = TimeZone(identifier: currentForecast.city.timezone) ?? .current
        let todayDaily = currentForecast.dailyWeather.first

        ScrollView(showsIndicators: false) {
            VStack(spacing: BaseNumeral.sectionSpacing) {
                // Индикатор офлайн-режима с давностью обновления кэша
                if isFromCache {
                    HStack(spacing: 6) {
                        Image(systemName: "wifi.slash")
                            .font(.caption2)

                        if let cacheAgeDescription {
                            Text(BaseText.Cache.withDescription + "\(cacheAgeDescription)")
                                .font(.caption2)
                                .fontWeight(.medium)
                        } else {
                            Text(BaseText.Cache.withoutDescription)
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
                    .clipShape(Capsule())
                    .padding(.top, 0)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Main.offlineBadge)
                }

                // Главный заголовок
                CurrentWeatherHeader(forecastData: currentForecast)

                // Почасовой прогноз
                HourlyForecast(
                    hourly: currentForecast.hourlyWeather,
                    timeZone: timeZone
                )

                // Прогноз на 7 дней
                DailyForecast(
                    daily: currentForecast.dailyWeather
                )

                // Сетка метрик в системе
                LazyVGrid(columns: columns, spacing: BaseNumeral.defaultSpacing) {
                    WindMetricCard(
                        speedMps: current.windSpeed,
                        directionString: current.windDirection,
                        gustMps: current.windGusts
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Metrics.wind)

                    PressureMetricCard(
                        pressureHpa: current.pressure,
                        pressureStatus: current.pressureStatus,
                        pressureMmHg: current.pressureMmHg
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Metrics.pressure)

                    HumidityMetricCard(
                        humidity: current.relativeHumidity,
                        dewPoint: current.dewPoint
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Metrics.humidity)

                    UVMetricCard(
                        uvIndex: todayDaily?.uVIndex ?? 0.0,
                        uvStatus: todayDaily?.uvStatus.descripiton ?? ""

                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Metrics.uv)

                    SunTimesMetricCard(
                        sunrise: todayDaily?.sunrise ?? "",
                        sunset: todayDaily?.sunset ?? ""
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Metrics.sun)

                    VisibilityMetricCard(
                        visibilityMeters: current.visibility
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Metrics.visibility)
                }
                .padding(.horizontal, BaseNumeral.screenHorizontalPadding)
                .padding(.bottom, BaseNumeral.screenBottomPadding)
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Main.scrollView)
        .refreshable {
            onPullToRefresh()
        }
    }
}
