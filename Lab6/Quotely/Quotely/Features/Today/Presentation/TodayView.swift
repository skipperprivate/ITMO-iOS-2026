//
//  TodayView.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 24.09.2026.
//

import SwiftUI

struct TodayView: View {
    @State private var viewModel = TodayViewModel()
    @AppStorage(SettingsStorage.Key.showAuthor) private var showAuthor = true

    var body: some View {
        NavigationStack {
            Group {
                if let quote = viewModel.quote {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(quote.text)
                            .font(.title3)

                        if showAuthor {
                            Text(quote.author)
                                .foregroundStyle(.secondary)
                        }

                        Button(quote.isFavorite ? "Убрать из избранного" : "В избранное") {
                            viewModel.toggleFavorite()
                        }
                        .buttonStyle(.bordered)

                        Spacer()

                        Button("Показать другую") {
                            viewModel.pickNew()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                } else {
                    Text("Нет цитат. Загрузите их в «Каталоге».")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Цитата дня")
        }
        .onAppear { viewModel.load() }
    }
}
