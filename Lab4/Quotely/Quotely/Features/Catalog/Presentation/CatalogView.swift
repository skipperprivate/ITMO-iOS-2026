//
//  CatalogView.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 24.09.2026.
//

import SwiftUI

struct CatalogView: View {
    @State private var viewModel = CatalogViewModel()
    @State private var editedQuote: Quote?

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.quotes) { quote in
                    Button {
                        editedQuote = quote
                    } label: {
                        QuoteRow(quote: quote)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .leading) {
                        Button(quote.isFavorite ? "Убрать" : "В избранное") {
                            viewModel.toggleFavorite(quote)
                        }
                    }
                }
                .onDelete { viewModel.delete(at: $0) }
            }
            .overlay {
                if viewModel.quotes.isEmpty {
                    Text("Нет цитат. Нажмите «Загрузить».")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationTitle("Каталог")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Загрузить") {
                        Task { await viewModel.importFromAPI() }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(item: $editedQuote) { quote in
                QuoteFormView(quote: quote) { text, author in
                    viewModel.update(quote, text: text, author: author)
                }
            }
        }
        .onAppear { viewModel.load() }
    }
}
