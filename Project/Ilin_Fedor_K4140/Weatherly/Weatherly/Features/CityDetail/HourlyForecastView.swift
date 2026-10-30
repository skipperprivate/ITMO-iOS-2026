//
//  HourlyForecastView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct HourlyForecastView: View {
    let entries: [HourlyTimelineEntry]
    let timeZone: TimeZone
    let unit: TemperatureUnit
    // nil hides the header row.
    var title: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                SectionHeader(title: title, systemImage: "clock")
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 6) {
                    ForEach(entries) { entry in
                        HourlyTile(entry: entry, timeZone: timeZone, unit: unit, showsPrecipitation: showsPrecipitation)
                    }
                }
                .padding(.horizontal, 10)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 10)
        .background(WeatherPalette.cardFill, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(WeatherPalette.hairline)
        }
    }

    private var showsPrecipitation: Bool {
        entries.contains { entry in
            if case .hour(let item, _) = entry { return item.precipitationChancePercent >= 30 }
            return false
        }
    }
}

private struct HourlyTile: View {
    let entry: HourlyTimelineEntry
    let timeZone: TimeZone
    let unit: TemperatureUnit
    let showsPrecipitation: Bool

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.wxCaptionBold)
                .foregroundStyle(isHighlighted ? .primary : .secondary)
            icon
                .frame(height: 24)
            Text(value)
                .font(isHourEntry ? .wxHeadline : .wxMicro)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if showsPrecipitation {
                Text(precipitationText)
                    .font(.wxMicro)
                    .foregroundStyle(WeatherPalette.precipitation)
            }
        }
        .frame(width: 54)
        .padding(.vertical, 8)
        .background(
            isHighlighted ? WeatherPalette.nowFill : WeatherPalette.tileFill,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }

    private var isHourEntry: Bool {
        if case .hour = entry { return true }
        return false
    }

    private var isHighlighted: Bool {
        if case .hour(_, let highlighted) = entry { return highlighted }
        return false
    }

    private var title: String {
        isHighlighted ? "Сейчас" : WeatherFormatter.time(entry.date, in: timeZone)
    }

    @ViewBuilder
    private var icon: some View {
        switch entry {
        case .hour(let item, _):
            WeatherIconView(condition: item.condition, isDaytime: item.isDaytime, size: 21)
        case .sunrise:
            Image(systemName: "sunrise.fill").symbolRenderingMode(.multicolor).font(.system(size: 20)).weatherIconShadow(size: 20)
        case .sunset:
            Image(systemName: "sunset.fill").symbolRenderingMode(.multicolor).font(.system(size: 20)).weatherIconShadow(size: 20)
        }
    }

    private var value: String {
        switch entry {
        case .hour(let item, _): WeatherFormatter.temperature(item.temperatureCelsius, unit: unit)
        case .sunrise: "Восход"
        case .sunset: "Закат"
        }
    }

    private var precipitationText: String {
        if case .hour(let item, _) = entry, item.precipitationChancePercent >= 30 {
            return "\(item.precipitationChancePercent)%"
        }
        return " "
    }
}

#if DEBUG
#Preview {
    let snapshot = PreviewSupport.snapshot
    return HourlyForecastView(
        entries: HourlyTimeline.entries(hours: snapshot.upcomingHourly(from: .now), days: snapshot.daily, highlightFirst: true),
        timeZone: snapshot.city.timeZone,
        unit: .celsius
    )
    .previewOnBackdrop()
}
#endif
