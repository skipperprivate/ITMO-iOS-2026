//
//  WeatherMetricCard.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

/// Карточка метеорологической метрики
public struct WeatherMetricCard<Content: View>: View {
    public let icon: String
    public let title: String
    public let content: Content

    public init(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(title.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            content
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 110)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// Ветер
public struct WindMetricCard: View {
    public let speedMps: Double
    public let directionDegrees: Int
    public let gustMps: Double?

    public init(speedMps: Double = 0.0, directionDegrees: Int = 0, gustMps: Double? = nil) {
        self.speedMps = speedMps
        self.directionDegrees = directionDegrees
        self.gustMps = gustMps
    }

    public var body: some View {
        let directionName = WeatherUIHelper.degreesToDirection(directionDegrees)

        WeatherMetricCard(icon: "wind", title: "Ветер") {
            VStack(alignment: .leading, spacing: 4) {
                Text(MetricFormatter.windSpeed(speedMps))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("Направление: \(directionName)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 2)

                if let gust = gustMps {
                    Text("Порывы до \(MetricFormatter.windSpeed(gust))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

// Давление
public struct PressureMetricCard: View {
    public let pressureHpa: Double

    public init(pressureHpa: Double = 1013.25) {
        self.pressureHpa = pressureHpa
    }

    public var body: some View {
        WeatherMetricCard(icon: "gauge.with.dots.needle.bottom.50percent", title: "Давление") {
            VStack(alignment: .leading, spacing: 4) {
                Text(MetricFormatter.pressure(pressureHpa))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Spacer(minLength: 2)

                Text(WeatherUIHelper.pressureStatus(for: pressureHpa))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text(MetricFormatter.pressureMmHg(pressureHpa))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

// Влажность
public struct HumidityMetricCard: View {
    public let humidity: Int
    public let dewPoint: Double

    public init(humidity: Int = 0, dewPoint: Double = 0.0) {
        self.humidity = humidity
        self.dewPoint = dewPoint
    }

    public var body: some View {
        WeatherMetricCard(icon: "humidity.fill", title: "Влажность") {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(humidity)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Spacer(minLength: 2)

                Text("Точка росы \(MetricFormatter.temperature(dewPoint))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// УФ-индекс
public struct UVMetricCard: View {
    public let uvIndex: Double

    public init(uvIndex: Double = 0.0) {
        self.uvIndex = uvIndex
    }

    public var body: some View {
        WeatherMetricCard(icon: "sun.max.fill", title: "УФ-индекс") {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.1f", uvIndex))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Spacer(minLength: 2)

                Text(WeatherUIHelper.uvStatus(for: uvIndex))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// Восход и закат
public struct SunTimesMetricCard: View {
    public let sunrise: String
    public let sunset: String

    public init(sunrise: String = "", sunset: String = "") {
        self.sunrise = sunrise
        self.sunset = sunset
    }

    public var body: some View {
        WeatherMetricCard(icon: "sunrise.fill", title: "Восход и закат") {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Восход")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(WeatherUIHelper.formatTimeString(sunrise))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Закат")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(WeatherUIHelper.formatTimeString(sunset))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .padding(.top, 4)

                Spacer(minLength: 2)
            }
        }
    }
}

// Видимость
public struct VisibilityMetricCard: View {
    public let visibilityMeters: Double

    public init(visibilityMeters: Double = 10000.0) {
        self.visibilityMeters = visibilityMeters
    }

    public var body: some View {
        WeatherMetricCard(icon: "eye.fill", title: "Видимость") {
            VStack(alignment: .leading, spacing: 4) {
                Text(MetricFormatter.visibility(visibilityMeters))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Spacer(minLength: 2)

                Text(WeatherUIHelper.visibilityStatus(for: visibilityMeters))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
