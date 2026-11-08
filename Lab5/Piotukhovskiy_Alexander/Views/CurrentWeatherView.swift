import SwiftUI

struct CurrentWeatherView: View {
    @EnvironmentObject private var weather: WeatherViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let city = weather.selectedCity {
                        Text(city.name).font(.largeTitle)
                        Text(city.locationDetails).foregroundStyle(.secondary)
                    }
                    if let forecast = weather.forecast {
                        Image(systemName: WeatherPresentation.symbol(for: forecast.current.weatherCode,
                                                                     isDay: forecast.current.isDay))
                            .font(.system(size: 64))
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                        Text(weather.temperatureText(forecast.current.temperature))
                            .font(.system(size: 56, weight: .bold))
                        Text(WeatherPresentation.description(for: forecast.current.weatherCode))
                            .font(.title2)
                        Text(weather.updatedText(forecast.loadedAt))
                            .font(.caption).foregroundStyle(.secondary)
                    } else if weather.isLoading {
                        ProgressView("Загружаем погоду...")
                    } else {
                        Text("Погода пока не загружена").foregroundStyle(.secondary)
                    }
                    Button("Обновить") { Task { await weather.refresh() } }
                        .buttonStyle(.borderedProminent)
                        .disabled(weather.isLoading)
                    NavigationLink("Выбрать город") {
                        CitySearchView(service: weather.cityService)
                    }
                    .buttonStyle(.bordered)
                    .disabled(weather.isLoading)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .scrollBounceBehavior(.always)
            .refreshable { await weather.refresh() }
            .navigationTitle("Погода сейчас")
        }
    }
}
