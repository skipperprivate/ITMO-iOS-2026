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
                Section("settings.display") {
                    Toggle("settings.show_author", isOn: $showAuthor)
                }

                Section("settings.storage") {
                    LabeledContent("settings.total", value: "\(viewModel.statistics.total)")
                    LabeledContent(
                        "settings.favorite_count",
                        value: "\(viewModel.statistics.favorites)"
                    )
                    LabeledContent("settings.authors", value: "\(viewModel.statistics.authors)")
                    LabeledContent(
                        "settings.average_length",
                        value: "\(viewModel.statistics.averageLength)"
                    )
                }

                Section {
                    Button("settings.reset") {
                        viewModel.resetSettings()
                    }
                    Button("settings.delete_all", role: .destructive) {
                        Task { await viewModel.deleteAllQuotes() }
                    }
                }
            }
            .navigationTitle("settings.title")
        }
        .task { await viewModel.load() }
    }
}
