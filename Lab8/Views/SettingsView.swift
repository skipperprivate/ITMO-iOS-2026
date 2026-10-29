import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var theme = "system"

    var body: some View {
        NavigationStack {
            Form {
                Picker("Тема приложения", selection: $theme) {
                    Text("Системная").tag("system")
                    Text("Светлая").tag("light")
                    Text("Тёмная").tag("dark")
                }
                .pickerStyle(.inline)
            }
            .navigationTitle("Настройки")
        }
    }
}