//
//  SettingsView.swift
//  RecipeBook
//
//  Created by Viktor Medyankin on 07.10.2026.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        
        Form {
            
            Section("Кухня") {
                
                Picker(
                    "Предпочтительная кухня",
                    selection: $viewModel.selectedCuisine
                ) {
                    Text("Все")
                        .tag("Все")
                    
                    Text("Итальянская")
                        .tag("Итальянская")
                    
                    Text("Японская")
                        .tag("Японская")
                    
                    Text("Мексиканская")
                        .tag("Мексиканская")
                    
                    Text("Индийская")
                        .tag("Индийская")
                }
                .onChange(
                    of: viewModel.selectedCuisine
                ) { _, newValue in
                    viewModel.saveCuisine(newValue)
                }
            }
            
            Section("Сортировка") {
                
                Picker(
                    "Сортировать по",
                    selection: $viewModel.sortOption
                ) {
                    ForEach(
                        viewModel.sortOptions,
                        id: \.self
                    ) { option in
                        Text(option)
                            .tag(option)
                    }
                }
                .onChange(
                    of: viewModel.sortOption
                ) { _, newValue in
                    viewModel.saveSortOption(newValue)
                }
            }
            
            Section {
                
                Button("Сбросить настройки") {
                    viewModel.resetSettings()
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle("Настройки")
    }
}
