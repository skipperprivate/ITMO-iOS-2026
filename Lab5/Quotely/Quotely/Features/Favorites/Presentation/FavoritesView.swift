//
//  FavoritesView.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 24.09.2026.
//

import SwiftUI

struct FavoritesView: View {
    @State private var viewModel = FavoritesViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.quotes) { quote in
                    QuoteRow(quote: quote)
                        .swipeActions(edge: .leading) {
                            Button("Убрать") {
                                viewModel.removeFromFavorites(quote)
                            }
                        }
                }
                .onDelete { viewModel.delete(at: $0) }
            }
            .overlay {
                if viewModel.quotes.isEmpty {
                    Text("Избранное пусто. Отметьте цитаты в «Каталоге».")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationTitle("Избранное")
        }
        .onAppear { viewModel.load() }
    }
}
