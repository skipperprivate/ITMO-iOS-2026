//
//  SettingsView.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 04.10.2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var theme: ThemeStore
    @StateObject private var viewModel: SettingsViewModel
    @State private var showClearAlert = false
    
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Внешний вид") {
                    Toggle(isOn: $theme.isDarkMode) {
                        Label("Темная тема", systemImage: theme.isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .tint(.indigo)
                }
                
                Section {
                    Button(role: .destructive) {
                        showClearAlert = true
                    } label: {
                        Label("Очистить избранное", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Настройки")
            .alert("Очистить избранное?", isPresented: $showClearAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Очистить", role: .destructive) { Task { await viewModel.clearFavorites() } }
            } message: { Text("Все сохранённые цитаты будут удалены.") }
        }
    }
}
