//
//  SettingsView.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var settingsVM: SettingsViewModel

    public init(settingsVM: SettingsViewModel) {
        self.settingsVM = settingsVM
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Тема оформления", selection: $settingsVM.appTheme) {
                        Text(AppThemeProps.system.title).tag(AppThemeProps.system)
                        Text(AppThemeProps.light.title).tag(AppThemeProps.light)
                        Text(AppThemeProps.dark.title).tag(AppThemeProps.dark)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Тема")
                }

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
        .preferredColorScheme(settingsVM.appTheme.colorScheme)
        .id(settingsVM.appTheme)
    }
}
