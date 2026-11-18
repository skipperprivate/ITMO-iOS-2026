//
//  SettingsView.swift
//  Lab2
//
//  Created by n grebenkin on 01.10.2026.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Form {
            Section {
                LabeledContent("От") {
                    TextField("От", text: $viewModel.minText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("До") {
                    TextField("До", text: $viewModel.maxText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
            } header: {
                Text("Диапазон генерации")
            } footer: {
                if !viewModel.isValid {
                    Text("Введите целые числа, «От» не больше «До»")
                        .foregroundStyle(.red)
                }
            }
            Section {
                Toggle("Сохранять в историю", isOn: $viewModel.savesHistory)
            }
            Section {
                Button("Сбросить настройки", role: .destructive, action: viewModel.reset)
            }
        }
        .navigationTitle("Настройки")
        .toolbar {
            Button("Сохранить") {
                viewModel.save()
                dismiss()
            }
            .disabled(!viewModel.isValid)
        }
        .onAppear(perform: viewModel.load)
    }
}
