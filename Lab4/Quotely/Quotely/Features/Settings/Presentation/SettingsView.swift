//
//  SettingsView.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 24.09.2026.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @AppStorage(SettingsStorage.Key.showAuthor) private var showAuthor = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Отображение") {
                    Toggle("Показывать автора", isOn: $showAuthor)
                }

                Section("Хранилище") {
                    LabeledContent("Всего цитат", value: "\(viewModel.quotesCount)")
                }

                Section {
                    Button("Сбросить настройки") {
                        viewModel.resetSettings()
                    }
                    Button("Удалить все цитаты", role: .destructive) {
                        viewModel.deleteAllQuotes()
                    }
                }
            }
            .navigationTitle("Настройки")
        }
        .onAppear { viewModel.load() }
    }
}
