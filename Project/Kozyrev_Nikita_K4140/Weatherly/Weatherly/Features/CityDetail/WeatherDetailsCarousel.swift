//
//  WeatherDetailsCarousel.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct WeatherDetailsCarousel: View {
    let current: CurrentWeather
    let today: DailyForecastItem?
    let timeZone: TimeZone
    let settings: AppSettings
    let now: Date

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                windCard
                humidityCard
                pressureCard
                uvCard
                if let today { sunCard(today) }
                visibilityCard
            }
            .padding(.horizontal, 16)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, -16)
    }

    private var windCard: some View {
        DetailCard(title: "Ветер", systemImage: "wind") {
            HStack(spacing: 12) {
                WindCompass(directionDegrees: current.windDirectionDegrees)
                    .frame(width: 54, height: 54)
                VStack(alignment: .leading, spacing: -2) {
                    Text(WeatherFormatter.windSpeedValue(current.windSpeedKmh, unit: settings.windSpeedUnit))
                        .font(.wxValue)
                    Text(settings.windSpeedUnit.symbol)
                        .font(.wxCaption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
            Text(WeatherDescriptions.wind(kmh: current.windSpeedKmh))
                .font(.wxSubheadlineBold)
            Text("Порывы до \(WeatherFormatter.windSpeed(current.windGustsKmh, unit: settings.windSpeedUnit))")
                .font(.wxCaption)
                .foregroundStyle(.secondary)
        }
    }

    private var humidityCard: some View {
        DetailCard(title: "Влажность", systemImage: "humidity.fill") {
            Text("\(current.humidityPercent)%")
                .font(.wxValue)
            Spacer(minLength: 0)
            Text(WeatherDescriptions.humidity(current.humidityPercent))
                .font(.wxSubheadlineBold)
            GaugeBar(
                fraction: Double(current.humidityPercent) / 100,
                colors: [Color(hex: 0x6FC3FF), Color(hex: 0x2F7BEA)]
            )
            .padding(.top, 6)
        }
    }

    private var pressureCard: some View {
        DetailCard(title: "Давление", systemImage: "gauge.with.dots.needle.33percent") {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(WeatherFormatter.pressureValue(current.pressureHPa, unit: settings.pressureUnit))
                    .font(.wxValue)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            Text(settings.pressureUnit.symbol)
                .font(.wxCaption)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Text(WeatherDescriptions.pressure(hPa: current.pressureHPa))
                .font(.wxSubheadlineBold)
            GaugeBar(
                fraction: (current.pressureHPa - 970) / 80,
                colors: [Color(hex: 0x7FB2FF), Color(hex: 0x8FD66B), Color(hex: 0xFFA94D)],
                style: .marker
            )
            .padding(.top, 6)
        }
    }

    private var uvCard: some View {
        DetailCard(title: "УФ-индекс", systemImage: "sun.max.fill") {
            Text("\(Int(current.uvIndex.rounded()))")
                .font(.wxValue)
            Spacer(minLength: 0)
            Text(WeatherDescriptions.uvIndex(current.uvIndex))
                .font(.wxSubheadlineBold)
            GaugeBar(
                fraction: current.uvIndex / 11,
                colors: [Color(hex: 0x5CC95C), Color(hex: 0xF5D547), Color(hex: 0xFF8C42), Color(hex: 0xE5484D), Color(hex: 0xA25DDC)],
                style: .marker
            )
            .padding(.top, 6)
        }
    }

    private func sunCard(_ today: DailyForecastItem) -> some View {
        DetailCard(title: "Солнце", systemImage: "sun.horizon.fill") {
            SunArcView(progress: sunProgress(today))
                .frame(height: 40)
                .padding(.horizontal, 4)
                .padding(.top, 4)
            Spacer(minLength: 0)
            sunRow(icon: "sunrise.fill", title: "Восход", date: today.sunrise)
            sunRow(icon: "sunset.fill", title: "Закат", date: today.sunset)
        }
    }

    private var visibilityCard: some View {
        DetailCard(title: "Видимость", systemImage: "eye.fill") {
            Text(WeatherFormatter.visibility(current.visibilityKm))
                .font(.wxValue)
            Spacer(minLength: 0)
            Text(WeatherDescriptions.visibility(km: current.visibilityKm))
                .font(.wxSubheadlineBold)
        }
    }

    private func sunRow(icon: String, title: String, date: Date) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 13))
                .weatherIconShadow(size: 13)
            Text(title)
                .font(.wxCaption)
                .foregroundStyle(.secondary)
            Spacer(minLength: 4)
            Text(WeatherFormatter.time(date, in: timeZone))
                .font(.wxCaptionBold)
                .monospacedDigit()
        }
    }

    private func sunProgress(_ day: DailyForecastItem) -> Double? {
        guard now >= day.sunrise, now <= day.sunset else { return nil }
        return now.timeIntervalSince(day.sunrise) / day.sunset.timeIntervalSince(day.sunrise)
    }
}

private struct DetailCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            SectionHeader(title: title, systemImage: systemImage)
                .padding(.bottom, 8)
            content
        }
        .padding(16)
        .frame(width: 164, height: 170, alignment: .topLeading)
        .background(WeatherPalette.cardFill, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(WeatherPalette.hairline)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct WindCompass: View {
    let directionDegrees: Double

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(WeatherPalette.ink.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [2, 4]))
            Text("С")
                .font(.wxMicro)
                .foregroundStyle(.secondary)
                .offset(y: -19)
            // Degrees say where the wind comes from; the arrow shows where it blows.
            Image(systemName: "location.north.fill")
                .font(.system(size: 18))
                .foregroundStyle(WeatherPalette.windArrow)
                .rotationEffect(.degrees(directionDegrees + 180))
        }
        .accessibilityLabel("Направление \(WeatherDescriptions.compassDirection(degrees: directionDegrees))")
    }
}

private struct SunArcView: View {
    // 0...1 while the sun is up, nil at night.
    let progress: Double?

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addQuadCurve(to: CGPoint(x: width, y: height), control: CGPoint(x: width / 2, y: -height))
                }
                .stroke(WeatherPalette.ink.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [3, 4]))

                if let progress {
                    let horizontalPosition = 2 * (1 - progress) * progress * (width / 2) + progress * progress * width
                    let verticalPosition = (1 - progress) * (1 - progress) * height
                        + 2 * (1 - progress) * progress * -height
                        + progress * progress * height
                    Circle()
                        .fill(Color(hex: 0xFFC83A))
                        .frame(width: 12, height: 12)
                        .shadow(color: Color(hex: 0xFFC83A).opacity(0.8), radius: 6)
                        .position(x: horizontalPosition, y: verticalPosition)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    let snapshot = PreviewSupport.snapshot
    return WeatherDetailsCarousel(
        current: snapshot.current,
        today: snapshot.today(now: .now),
        timeZone: snapshot.city.timeZone,
        settings: .default,
        now: .now
    )
    .previewOnBackdrop()
}
#endif
