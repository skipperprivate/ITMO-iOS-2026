//
//  DayDetailView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct DayDetailView: View {
    @State private var viewModel: DayDetailViewModel
    @Environment(SettingsStore.self) private var settingsStore
    @Environment(WeatherAmbience.self) private var ambience

    init(viewModel: DayDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            // The day's own sky in the Home day/night grade.
            WeatherBackgroundView(condition: viewModel.day?.condition ?? ambience.condition, isDaytime: ambience.isDaytime)
            ScrollView {
                Group {
                    switch viewModel.state {
                    case .unavailable:
                        StateMessageView(
                            title: "Нет прогноза на этот день",
                            message: "День вышел за пределы 10-дневного прогноза",
                            systemImage: "calendar.badge.exclamationmark"
                        )
                        .padding(.top, 120)
                    case .loaded(let day, let hours):
                        content(day: day, hours: hours)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .weatherScreenStyle()
        .navigationTitle(WeatherFormatter.weekday(viewModel.date, calendar: viewModel.city.calendar))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(day: DailyForecastItem, hours: [HourlyForecastItem]) -> some View {
        let settings = settingsStore.settings
        let timeZone = viewModel.city.timeZone

        return VStack(spacing: 14) {
            DayHeroView(day: day, city: viewModel.city, unit: settings.temperatureUnit)
                .padding(.bottom, 10)

            if !hours.isEmpty {
                TemperatureChartView(hours: hours, timeZone: timeZone, unit: settings.temperatureUnit)
                HourlyForecastView(
                    entries: HourlyTimeline.entries(hours: hours, days: [day], highlightFirst: false),
                    timeZone: timeZone,
                    unit: settings.temperatureUnit,
                    title: "По часам"
                )
            }

            DaySummaryGrid(day: day, timeZone: timeZone, settings: settings)

            ForecastFooterView(updatedAt: nil, now: .now)
        }
    }
}

private struct DayHeroView: View {
    let day: DailyForecastItem
    let city: City
    let unit: TemperatureUnit

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(city.name), \(WeatherFormatter.dayMonth(day.date, in: city.timeZone))")
                    .font(.wxHeadline)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 18) {
                    temperature(day.maxTemperatureCelsius, caption: "днём", isPrimary: true)
                    temperature(day.minTemperatureCelsius, caption: "ночью", isPrimary: false)
                }
                Text(day.condition.label)
                    .font(.wxTitle2)
            }
            Spacer(minLength: 8)
            WeatherIconView(condition: day.condition, isDaytime: true, size: 92, floats: true)
                .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }

    private func temperature(_ value: Double, caption: String, isPrimary: Bool) -> some View {
        VStack(alignment: .leading, spacing: -4) {
            Text(WeatherFormatter.temperature(value, unit: unit))
                .font(isPrimary ? .wxDisplay : .wxDisplaySecondary)
                .foregroundStyle(isPrimary ? .primary : .secondary)
            Text(caption)
                .font(.wxCaptionBold)
                .foregroundStyle(.secondary)
        }
    }
}

private struct DaySummaryGrid: View {
    let day: DailyForecastItem
    let timeZone: TimeZone
    let settings: AppSettings

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            tile(icon: "drop.fill", title: "Вероятность", value: "\(day.precipitationChancePercent)%", tint: WeatherPalette.precipitation)
            tile(icon: "cloud.rain.fill", title: "Осадки", value: WeatherFormatter.precipitation(day.precipitationSumMm))
            tile(icon: "wind", title: "Ветер до", value: WeatherFormatter.windSpeed(day.windSpeedMaxKmh, unit: settings.windSpeedUnit))
            tile(icon: "sun.max.fill", title: "УФ-индекс", value: "\(Int(day.uvIndexMax.rounded()))")
            tile(icon: "sunrise.fill", title: "Восход", value: WeatherFormatter.time(day.sunrise, in: timeZone))
            tile(icon: "sunset.fill", title: "Закат", value: WeatherFormatter.time(day.sunset, in: timeZone))
        }
    }

    // tint affects only single-layer symbols.
    private func tile(icon: String, title: String, value: String, tint: Color = WeatherPalette.ink) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .symbolRenderingMode(.multicolor)
                .foregroundStyle(tint)
                .font(.system(size: 20))
                .weatherIconShadow(size: 20)
                .frame(height: 26)
            Text(value)
                .font(.wxHeadline)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.wxCaption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .background(WeatherPalette.cardFill, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(WeatherPalette.hairline)
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    DayDetailView(viewModel: DayDetailViewModel(snapshot: PreviewSupport.snapshot, date: .now))
    .previewEnvironment()
}
#endif
