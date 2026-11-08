import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var weather: WeatherViewModel

    var body: some View {
        Group {
            if let error = weather.storageError {
                ContentUnavailableView("Хранилище недоступно", systemImage: "externaldrive.badge.exclamationmark",
                                       description: Text(error))
            } else if weather.selectedCity == nil {
                NavigationStack {
                    CitySearchView(service: weather.cityService, isRequired: true)
                }
            } else {
                TabView {
                    CurrentWeatherView()
                        .tabItem { Label("Сейчас", systemImage: "sun.max") }
                    HourlyForecastView()
                        .tabItem { Label("По часам", systemImage: "clock") }
                    DailyForecastView()
                        .tabItem { Label("По дням", systemImage: "calendar") }
                    SettingsView()
                        .tabItem { Label("Настройки", systemImage: "gearshape") }
                }
            }
        }
        .task {
            await weather.loadInitialForecastIfNeeded()
        }
        .alert(item: $weather.alert) { item in
            Alert(title: Text(item.message), dismissButton: .default(Text("ОК")))
        }
    }
}
