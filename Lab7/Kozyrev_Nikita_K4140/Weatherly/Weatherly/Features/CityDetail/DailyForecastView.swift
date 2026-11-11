//
//  DailyForecastView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct DailyForecastView: View {
    let days: [DailyForecastItem]
    let calendar: Calendar
    let unit: TemperatureUnit
    let onSelect: (DailyForecastItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                SectionHeader(title: "Прогноз на \(WeatherFormatter.days(days.count))", systemImage: "calendar")
                Text("День").frame(width: DailyForecastRow.dayColumn)
                Text("Ночь").frame(width: DailyForecastRow.nightColumn)
                Color.clear.frame(width: DailyForecastRow.chevronColumn)
            }
            .font(.wxCaptionBold)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 6)

            ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                Button {
                    onSelect(day)
                } label: {
                    DailyForecastRow(day: day, calendar: calendar, unit: unit)
                }
                .buttonStyle(PressableRowStyle())

                if index < days.count - 1, !calendar.isDateInToday(day.date) {
                    Rectangle()
                        .fill(WeatherPalette.ink.opacity(0.08))
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.bottom, 8)
        .background(WeatherPalette.cardFill, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(WeatherPalette.hairline)
        }
    }
}

private struct DailyForecastRow: View {
    static let dayColumn: CGFloat = 52
    static let nightColumn: CGFloat = 50
    static let chevronColumn: CGFloat = 8

    let day: DailyForecastItem
    let calendar: Calendar
    let unit: TemperatureUnit

    var body: some View {
        let isToday = calendar.isDateInToday(day.date)
        let isWeekend = calendar.isDateInWeekend(day.date)
        let accent = isWeekend ? AnyShapeStyle(WeatherPalette.weekend) : AnyShapeStyle(.primary)

        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 1) {
                Text(WeatherFormatter.weekday(day.date, calendar: calendar))
                    .font(isToday ? .wxBodyBold : .wxBody)
                    .foregroundStyle(accent)
                Text(WeatherFormatter.dayMonth(day.date, in: calendar.timeZone))
                    .font(.wxCaption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                if day.precipitationChancePercent >= 30 {
                    Text("\(day.precipitationChancePercent)%")
                        .font(.wxMicro)
                        .foregroundStyle(WeatherPalette.precipitation)
                }
                WeatherIconView(condition: day.condition, isDaytime: true, size: 23)
                    .frame(width: 32)
            }
            .frame(width: 68, alignment: .trailing)

            Text(WeatherFormatter.temperature(day.maxTemperatureCelsius, unit: unit))
                .font(.wxTitle3)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: Self.dayColumn)
            Text(WeatherFormatter.temperature(day.minTemperatureCelsius, unit: unit))
                .font(.wxTitle3Regular)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: Self.nightColumn)
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tertiary)
                .frame(width: Self.chevronColumn)
        }
        .monospacedDigit()
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            if isToday {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(WeatherPalette.tileFill)
                    .padding(.horizontal, 6)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    let snapshot = PreviewSupport.snapshot
    return ScrollView {
        DailyForecastView(days: snapshot.daily, calendar: snapshot.city.calendar, unit: .celsius) { _ in }
    }
    .previewOnBackdrop(isDaytime: true)
}
#endif
