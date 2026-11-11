//
//  SettingsView.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTheme: AppThemeProps
    public let onColorThemeChange: (AppThemeProps) -> Void

    public init(
        currentColorScheme: ColorScheme? = nil,
        onColorThemeChange: @escaping (AppThemeProps) -> Void
    ) {
        self.onColorThemeChange = onColorThemeChange
        let initialTheme = AppThemeProps.allCases.first(where: { $0.colorScheme == currentColorScheme }) ?? .system
        self._selectedTheme = State(initialValue: initialTheme)
    }

    public init(
        settingsVM: SettingsViewModel,
        onColorThemeChange: ((AppThemeProps) -> Void)? = nil
    ) {
        self.onColorThemeChange = onColorThemeChange ?? { theme in
            settingsVM.appTheme = theme
        }
        self._selectedTheme = State(initialValue: settingsVM.appTheme)
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Внешний вид
                Section {
                    Picker("Тема оформления", selection: $selectedTheme) {
                        ForEach(AppThemeProps.allCases, id: \.title) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedTheme) { _, newTheme in
                        onColorThemeChange(newTheme)
                    }
                } header: {
                    Text("Тема")
                }

                // Единицы измерения
                Section {
                    LabeledContent("Температура", value: "°C (Цельсий)")
                    LabeledContent("Скорость ветра", value: "м/с (Метры в секунду)")
                    LabeledContent("Давление", value: "гПа (Гектопаскали)")
                    LabeledContent("Видимость", value: "км (Километры)")
                } header: {
                    Text("Единицы измерения")
                }

            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .preferredColorScheme(selectedTheme.colorScheme)
    }
}
