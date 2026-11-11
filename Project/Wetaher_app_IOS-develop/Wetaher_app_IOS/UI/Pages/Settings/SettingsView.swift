//
//  SettingsView.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var appTheme: AppThemeProps

    public init(appTheme: Binding<AppThemeProps>) {
        self._appTheme = appTheme
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Внешний вид
                Section {
                    Picker(BaseText.Settings.themePicker, selection: $appTheme) {
                        ForEach(AppThemeProps.allCases, id: \.title) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Settings.themePicker)
                } header: {
                    Text(BaseText.Settings.themeSection)
                }

                // Единицы измерения
                Section {
                    LabeledContent(BaseText.Settings.temperature, value: BaseText.Settings.temperatureUnit)
                    LabeledContent(BaseText.Settings.windSpeed, value: BaseText.Settings.windSpeedUnit)
                    LabeledContent(BaseText.Settings.pressure, value: BaseText.Settings.pressureUnit)
                    LabeledContent(BaseText.Settings.visibility, value: BaseText.Settings.visibilityUnit)
                } header: {
                    Text(BaseText.Settings.unitsSection)
                }

            }
            .navigationTitle(BaseText.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(BaseText.Common.done) {
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .accessibilityIdentifier(AccessibilityIdentifiers.Settings.doneButton)
                }
            }
        }
    }
}
