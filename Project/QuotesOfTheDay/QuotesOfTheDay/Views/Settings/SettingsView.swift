import SwiftUI
import SwiftData

struct SettingsView: View {

    @AppStorage("appTheme") private var appTheme = "system"

    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<SavedQuote> { quote in
            quote.isInHistory == true
        }
    )
    private var history: [SavedQuote]

    var body: some View {
        NavigationStack {
            Form {

                Section("Оформление") {
                    Picker("Тема", selection: $appTheme) {
                        Text("Системная")
                            .tag("system")

                        Text("Светлая")
                            .tag("light")

                        Text("Тёмная")
                            .tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Данные") {
                    Button("Очистить историю", role: .destructive) {
                        clearHistory()
                    }
                }

                Section("О приложении") {
                    HStack {
                        Text("Версия")

                        Spacer()

                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }

    private func clearHistory() {
        for quote in history {
            quote.isInHistory = false

            if quote.isFavorite == false {
                modelContext.delete(quote)
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: SavedQuote.self, inMemory: true)
}
