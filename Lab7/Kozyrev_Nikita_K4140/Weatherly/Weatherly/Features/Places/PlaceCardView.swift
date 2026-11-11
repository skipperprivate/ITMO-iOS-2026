//
//  PlaceCardView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct PlaceCardView: View {
    let city: City
    let weather: PlaceWeather
    let unit: TemperatureUnit

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(.wxTitle3)
                    .lineLimit(1)
                // The card only redraws when weather changes, so the local clock needs its own tick.
                TimelineView(.everyMinute) { context in
                    Text(subtitle(now: context.date))
                        .font(.wxCaption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            trailing
        }
        .foregroundStyle(WeatherPalette.ink)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(colors: backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(WeatherPalette.hairline)
        }
        .shadow(color: WeatherPalette.shadow, radius: 10, y: 4)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var trailing: some View {
        switch weather {
        case .loading:
            ProgressView()
        case .loaded(let current):
            Text(WeatherFormatter.temperature(current.temperatureCelsius, unit: unit))
                .font(.wxValue)
                .monospacedDigit()
                .lineLimit(1)
            WeatherIconView(condition: current.condition, isDaytime: current.isDaytime, size: 28)
                .frame(width: 36)
        case .unavailable:
            Text("—")
                .font(.wxValue)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Нет данных о погоде")
        }
    }

    private var current: CurrentWeather? {
        if case .loaded(let current) = weather { return current }
        return nil
    }

    private func subtitle(now: Date) -> String {
        guard let current else { return city.subtitle }
        return "\(WeatherFormatter.time(now, in: city.timeZone)) · \(current.condition.label)"
    }

    private var backgroundColors: [Color] {
        WeatherPalette.backgroundColors(for: current?.condition, isDaytime: current?.isDaytime ?? true, scheme: colorScheme)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        ForEach(MockData.allCities.prefix(3)) { city in
            PlaceCardView(city: city, weather: .loaded(MockData.snapshot(for: city).current), unit: .celsius)
        }
        PlaceCardView(city: MockData.allCities[4], weather: .loading, unit: .celsius)
        PlaceCardView(city: MockData.allCities[5], weather: .unavailable, unit: .celsius)
    }
    .previewOnBackdrop()
}
#endif
