//
//  GeneratorScreen.swift
//  Lab2
//
//  Created by Nikita Kozyrev on 17.09.2026.
//

import SwiftUI

struct GeneratorScreen: View {
    @State private var viewModel = GeneratorViewModel()

    var body: some View {
        VStack(spacing: 32) {
            Text("Сгенерированное число")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(viewModel.displayText)
                .font(.system(size: 72, weight: .heavy, design: .monospaced))
                .contentTransition(.numericText())
                .animation(.snappy, value: viewModel.currentValue)
                .accessibilityIdentifier("numberLabel")

            VStack(spacing: 16) {
                Button("Сгенерировать число", action: viewModel.roll)
                    .buttonStyle(.borderedProminent)

                NavigationLink("Переход на второй экран") {
                    GalleryScreen()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Главный экран")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GeneratorScreen()
    }
}
