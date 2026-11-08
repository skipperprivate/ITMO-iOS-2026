import SwiftUI

struct DailyForecastView: View {
    @EnvironmentObject private var weather: WeatherViewModel

    var body: some View {
        NavigationStack {
            List {
                Section { ForecastStatusView() }
                if let forecast = weather.forecast {
                    Section("Прогноз на \(AppConstants.dailyForecastCount) дней") {
                        ForEach(forecast.daily) { day in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(weather.dayText(day.date)).font(.headline)
                                Label(WeatherPresentation.description(for: day.weatherCode),
                                      systemImage: WeatherPresentation.symbol(for: day.weatherCode))
                                    .foregroundStyle(.secondary)
                                Text("От \(weather.temperatureText(day.minimum)) до \(weather.temperatureText(day.maximum))")
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
            .navigationTitle("По дням")
        }
    }
}
