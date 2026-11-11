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
        VStack(alignment: .leading, spacing: BaseNumeral.smallSpacing) {
            HStack(spacing: BaseNumeral.textSpacing) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(Colors.secondaryText)
                Text(title.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Colors.secondaryText)
            }

            content
        }
        .padding(BaseNumeral.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: BaseNumeral.metricCardMinHeight)
        .background(Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: BaseNumeral.cardCornerRadius, style: .continuous))
    }
}

// Ветер
public struct WindMetricCard: View {
    public let speedMps: Double
    public let direction: String
    public let gustMps: Double?

    public init(speedMps: Double = 0.0, directionString: String = BaseText.Metrics.defaultDirection, gustMps: Double? = nil) {
        self.speedMps = speedMps
        self.direction = directionString
        self.gustMps = gustMps
    }

    public var body: some View {
        // let directionName = WeatherUIHelper.degreesToDirection(direction)

        WeatherMetricCard(icon: "wind", title: BaseText.Metrics.wind) {
            VStack(alignment: .leading, spacing: BaseNumeral.textSpacing) {
                Text(MetricFormatter.windSpeed(speedMps))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Colors.primaryText)

                Text(BaseText.Metrics.windDirection(direction))
                    .font(.footnote)
                    .foregroundStyle(Colors.secondaryText)

                Spacer(minLength: BaseNumeral.textSpacing)

                if let gust = gustMps {
                    Text(BaseText.Metrics.windGusts(MetricFormatter.windSpeed(gust)))
                        .font(.caption)
                        .foregroundStyle(Colors.tertiaryText)
                }
            }
        }
    }
}

// Давление
public struct PressureMetricCard: View {
    public let pressureHpa: Double
    public let pressureStatus: String
    public let pressureMmHg: Int

    public init(pressureHpa: Double = 1013.25, pressureStatus: String = "", pressureMmHg: Int = 1012) {
        self.pressureHpa = pressureHpa
        self.pressureMmHg = pressureMmHg
        self.pressureStatus = pressureStatus
    }

    public var body: some View {
        WeatherMetricCard(icon: "gauge.with.dots.needle.bottom.50percent", title: BaseText.Metrics.pressure) {
            VStack(alignment: .leading, spacing: BaseNumeral.textSpacing) {
                Text(MetricFormatter.pressure(pressureHpa))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Colors.primaryText)

                Spacer(minLength: BaseNumeral.textSpacing)

                Text(pressureStatus)
                    .font(.footnote)
                    .foregroundStyle(Colors.secondaryText)

                Text(MetricFormatter.pressureMmHg(pressureMmHg))
                    .font(.caption2)
                    .foregroundStyle(Colors.tertiaryText)
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
        WeatherMetricCard(icon: "humidity.fill", title: BaseText.Metrics.humidity) {
            VStack(alignment: .leading, spacing: BaseNumeral.textSpacing) {
                Text(BaseText.Metrics.percent(humidity))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Colors.primaryText)

                Spacer(minLength: BaseNumeral.textSpacing)

                Text(BaseText.Metrics.dewPoint(MetricFormatter.temperature(dewPoint, showSign: false)))
                    .font(.footnote)
                    .foregroundStyle(Colors.secondaryText)
            }
        }
    }
}

// УФ-индекс
public struct UVMetricCard: View {
    public let uvIndex: Double
    public let uvStatus: String

    public init(uvIndex: Double = 0.0, uvStatus: String = "") {
        self.uvIndex = uvIndex
        self.uvStatus = uvStatus
    }

    public var body: some View {
        WeatherMetricCard(icon: "sun.max.fill", title: BaseText.Metrics.uvIndex) {
            VStack(alignment: .leading, spacing: BaseNumeral.textSpacing) {
                Text(String(format: "%.1f", uvIndex))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Colors.primaryText)

                Spacer(minLength: BaseNumeral.textSpacing)

                Text(uvStatus)
                    .font(.footnote)
                    .foregroundStyle(Colors.secondaryText)
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
        WeatherMetricCard(icon: "sunrise.fill", title: BaseText.Metrics.sunTimes) {
            VStack(alignment: .leading, spacing: BaseNumeral.textSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: BaseNumeral.textSpacing) {
                        Text(BaseText.Metrics.sunrise)
                            .font(.caption2)
                            .foregroundStyle(Colors.secondaryText)
                        Text(sunrise)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: BaseNumeral.textSpacing) {
                        Text(BaseText.Metrics.sunset)
                            .font(.caption2)
                            .foregroundStyle(Colors.secondaryText)
                        Text(sunset)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .padding(.top, BaseNumeral.textSpacing)

                Spacer(minLength: BaseNumeral.textSpacing)
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
        WeatherMetricCard(icon: "eye.fill", title: BaseText.Metrics.visibility) {
            VStack(alignment: .leading, spacing: BaseNumeral.textSpacing) {
                Text(MetricFormatter.visibility(visibilityMeters))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Colors.primaryText)

                Spacer(minLength: BaseNumeral.textSpacing)

                Text(WeatherUIHelper.visibilityStatus(for: visibilityMeters))
                    .font(.footnote)
                    .foregroundStyle(Colors.secondaryText)
            }
        }
    }
}
