//
//  TemperatureChartView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI
import Charts

struct TemperatureChartView: View {
    let hours: [HourlyForecastItem]
    let timeZone: TimeZone
    let unit: TemperatureUnit

    var body: some View {
        let domain = temperatureDomain
        let ink = WeatherPalette.ink

        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Температура", systemImage: "thermometer.medium")
            Chart(hours) { item in
                let value = unit.convert(fromCelsius: item.temperatureCelsius)
                AreaMark(
                    x: .value("Время", item.date),
                    yStart: .value("Минимум", domain.lowerBound),
                    yEnd: .value("Температура", value)
                )
                .foregroundStyle(LinearGradient(colors: [ink.opacity(0.28), ink.opacity(0.02)], startPoint: .top, endPoint: .bottom))
                .interpolationMethod(.catmullRom)

                LineMark(x: .value("Время", item.date), y: .value("Температура", value))
                    .foregroundStyle(ink)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: domain)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) { _ in
                    AxisGridLine().foregroundStyle(ink.opacity(0.12))
                    AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .omitted)))
                        .font(.wxCaption)
                        .foregroundStyle(ink.opacity(0.7))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine().foregroundStyle(ink.opacity(0.12))
                    AxisValueLabel {
                        if let degrees = value.as(Double.self) {
                            Text("\(Int(degrees.rounded()))°")
                        }
                    }
                    .font(.wxCaption)
                    .foregroundStyle(ink.opacity(0.7))
                }
            }
            .environment(\.timeZone, timeZone)
            .frame(height: 170)
        }
        .glassCard(cornerRadius: 26)
    }

    private var temperatureDomain: ClosedRange<Double> {
        let values = hours.map { unit.convert(fromCelsius: $0.temperatureCelsius) }
        let low = (values.min() ?? 0) - 2
        let high = (values.max() ?? 0) + 2
        return low...high
    }
}

#if DEBUG
#Preview {
    TemperatureChartView(
        hours: PreviewSupport.snapshot.hourlyItems(on: .now),
        timeZone: PreviewSupport.city.timeZone,
        unit: .celsius
    )
    .previewOnBackdrop()
}
#endif
