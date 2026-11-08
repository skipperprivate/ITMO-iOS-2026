import SwiftUI

struct ForecastStatusView: View {
    @EnvironmentObject private var weather: WeatherViewModel

    var body: some View {
        if let city = weather.selectedCity {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.name).font(.headline)
                Text(city.locationDetails).font(.subheadline)
                if let forecast = weather.forecast {
                    Text(weather.updatedText(forecast.loadedAt)).font(.caption)
                }
            }
            .foregroundStyle(.secondary)
            .padding(.vertical, 4)
        }
    }
}
