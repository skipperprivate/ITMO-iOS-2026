//
//  NumberView.swift
//  Lab2
//
//  Created by n grebenkin on 24.09.2026.
//

import SwiftUI

struct NumberView: View {
    @State private var viewModel: NumberViewModel
    @State private var historyViewModel: HistoryViewModel
    @State private var settingsViewModel: SettingsViewModel

    init(viewModel: NumberViewModel, historyViewModel: HistoryViewModel, settingsViewModel: SettingsViewModel) {
        self.viewModel = viewModel
        self.historyViewModel = historyViewModel
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text(viewModel.numberText)
                Text(viewModel.rangeText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Сгенерировать число") { viewModel.generateNumber()
                }.buttonStyle(.borderedProminent)
                Spacer()
                NavigationLink("История генераций") { HistoryView(viewModel: historyViewModel) }
                NavigationLink("Настройки") { SettingsView(viewModel: settingsViewModel) }
            }
            .onAppear { viewModel.reloadSettings() }
        }
    }
}
