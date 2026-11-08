import SwiftUI

struct HourlyForecastView: View {
    @EnvironmentObject private var weather: WeatherViewModel

    var body: some View {
        NavigationStack {
            List {
                Section { ForecastStatusView() }
                if let forecast = weather.forecast {
                    Section("Прогноз по часам") {
                        ForEach(forecast.hourly) { hour in
                            HStack(spacing: 12) {
                                Text(weather.hourText(hour.date)).monospacedDigit()
                                VStack(alignment: .leading, spacing: 4) {
                                    Label(WeatherPresentation.description(for: hour.weatherCode),
                                          systemImage: WeatherPresentation.symbol(for: hour.weatherCode,
                                                                                  isDay: hour.isDay))
                                        .font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 4)
                                Text(weather.temperatureText(hour.temperature))
                                    .monospacedDigit()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else if weather.isLoading {
                    ProgressView("Загружаем погоду...")
                } else {
                    Text("Потяните вниз, чтобы загрузить прогноз")
                        .foregroundStyle(.secondary)
                }
            }
            .refreshable { await weather.refresh() }
            .navigationTitle("По часам")
        }
    }
}
