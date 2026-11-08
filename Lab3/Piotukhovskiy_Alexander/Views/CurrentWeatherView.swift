import SwiftUI

struct CurrentWeatherView: View {
    @EnvironmentObject private var weather: WeatherViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(weather.city)
                    .font(.largeTitle)

                Text(weather.temperatureText(weather.currentTemperature))
                    .font(.system(size: 56, weight: .bold))

                Text(weather.currentCondition)
                    .font(.title2)

                Text("Synthetic data")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Refresh") {
                    weather.refresh()
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("Find city") {
                    CitySearchView()
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .navigationTitle("Current weather")
        }
    }
}
