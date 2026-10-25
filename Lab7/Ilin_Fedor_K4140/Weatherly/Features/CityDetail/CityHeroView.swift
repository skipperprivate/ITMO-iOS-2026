import SwiftUI

struct CityHeroView: View {
    let snapshot: CityWeatherSnapshot
    let summary: String
    let now: Date
    let unit: TemperatureUnit

    var body: some View {
        let current = snapshot.current

        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(WeatherFormatter.temperature(current.temperatureCelsius, unit: unit))
                        .font(.wxHero)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Text("ощущается как \(WeatherFormatter.temperature(current.feelsLikeCelsius, unit: unit))")
                        .font(.wxHeadline)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                WeatherIconView(condition: current.condition, isDaytime: current.isDaytime, size: 92, floats: true)
                    .padding(.top, 20)
                    .padding(.trailing, 6)
            }

            Text(current.condition.label)
                .font(.wxTitle2)
                .padding(.top, 10)

            Text(summary)
                .font(.wxBodyBold)
                .foregroundStyle(.secondary)

            if let today = snapshot.today(now: now) {
                HStack(spacing: 14) {
                    Label(WeatherFormatter.temperature(today.maxTemperatureCelsius, unit: unit), systemImage: "arrow.up")
                    Label(WeatherFormatter.temperature(today.minTemperatureCelsius, unit: unit), systemImage: "arrow.down")
                }
                .font(.wxSubheadlineBold)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("city.weather.\(snapshot.city.id)")
    }
}

#Preview {
    CityHeroView(snapshot: PreviewSupport.snapshot, summary: "Сегодня осадков не ожидается", now: .now, unit: .celsius)
        .previewOnBackdrop()
}
