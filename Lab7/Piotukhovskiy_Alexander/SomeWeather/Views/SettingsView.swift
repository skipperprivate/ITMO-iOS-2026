import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var weather: WeatherViewModel
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Температура") {
                    Toggle("Показывать в фаренгейтах", isOn: $weather.useFahrenheit)
                }
                Section("Город") {
                    if let city = weather.selectedCity {
                        CityRow(city: city, isSelected: false)
                    }
                    NavigationLink("Изменить город") {
                        CitySearchView(service: weather.cityService)
                    }
                    .disabled(weather.isLoading)
                }
                Section {
                    Button("Сбросить настройки", role: .destructive) {
                        showResetConfirmation = true
                    }
                    .disabled(weather.isLoading)
                }
            }
            .navigationTitle("Настройки")
            .confirmationDialog("Сбросить настройки?", isPresented: $showResetConfirmation,
                                titleVisibility: .visible) {
                Button("Сбросить", role: .destructive) { weather.resetSettings() }
                Button("Отмена", role: .cancel) {}
            }
        }
    }
}
