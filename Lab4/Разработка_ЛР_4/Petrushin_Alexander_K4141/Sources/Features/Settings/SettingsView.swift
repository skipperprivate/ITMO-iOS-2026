//
//  SettingsView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @Environment(WeatherAmbience.self) private var ambience

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 22) {
                    SettingGroup(title: "Температура", systemImage: "thermometer.medium") {
                        PillPicker(options: TemperatureUnit.allCases, selection: $viewModel.settings.temperatureUnit) { $0.symbol }
                    }
                    SettingGroup(title: "Сила ветра", systemImage: "wind") {
                        PillPicker(options: WindSpeedUnit.allCases, selection: $viewModel.settings.windSpeedUnit) { $0.symbol }
                    }
                    SettingGroup(title: "Давление", systemImage: "gauge.with.dots.needle.33percent") {
                        PillPicker(options: PressureUnit.allCases, selection: $viewModel.settings.pressureUnit) { $0.symbol }
                    }
                }
                .glassCard(cornerRadius: 26, padding: 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Оформление")
                        .font(.wxTitle2)
                    PillPicker(options: AppTheme.allCases, selection: $viewModel.settings.theme) { $0.label }
                    Text("«Авто» — светлое днём и тёмное ночью в городе на главном экране")
                        .font(.wxCaption)
                        .foregroundStyle(.secondary)
                }
                .glassCard(cornerRadius: 26, padding: 20)

                VStack(spacing: 0) {
                    Link(destination: DataAttribution.url) {
                        InfoRow(title: "Данные о погоде", value: "Open-Meteo ↗", systemImage: "cloud.sun.fill")
                    }
                    .accessibilityHint("Открыть сайт источника данных, лицензия \(DataAttribution.license)")
                    Rectangle()
                        .fill(WeatherPalette.ink.opacity(0.08))
                        .frame(height: 1)
                        .padding(.leading, 56)
                    InfoRow(title: "Версия", value: viewModel.appVersion, systemImage: "info.circle.fill")
                }
                .glassCard(cornerRadius: 26, padding: 0)
            }
            .padding(16)
        }
        .ambientBackground(ambience)
        .weatherScreenStyle()
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SettingGroup<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                Text(title)
                    .font(.wxHeadline)
            }
            content
        }
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 20))
                .weatherIconShadow(size: 20)
                .frame(width: 28)
            Text(title).font(.wxBody)
            Spacer()
            Text(value).font(.wxBody).foregroundStyle(.secondary).lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(store: PreviewSupport.settingsStore))
        .previewEnvironment()
}
