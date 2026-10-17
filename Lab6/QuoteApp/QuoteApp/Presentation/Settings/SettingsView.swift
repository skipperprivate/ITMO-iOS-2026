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
                
                
            }
            .navigationTitle("Настройки")
        }
    }
}
