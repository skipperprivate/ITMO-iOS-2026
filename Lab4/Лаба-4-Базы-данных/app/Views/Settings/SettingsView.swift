import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SettingsViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Form {
                Section {
                    Toggle("Показывать даты публикаций", isOn: $viewModel.showDates)
                    Button("Сбросить настройку") {
                        viewModel.reset()
                    }
                } footer: {
                    Text("Приложение запоминает настройку после закрытия. При сбросе даты снова отображаются.")
                }
            }
            .navigationTitle("Настройки")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
        }
    }
}
