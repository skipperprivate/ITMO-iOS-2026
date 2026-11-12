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

    private func favoriteActionTitle(for quote: Quote) -> LocalizedStringKey {
        quote.isFavorite ? "catalog.remove" : "catalog.favorite"
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.quotes) { quote in
                    Button {
                        viewModel.errorMessage = nil
                        editedQuote = quote
                    } label: {
                        QuoteRow(quote: quote)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isLoading)
                    .swipeActions(edge: .leading) {
                        Button(favoriteActionTitle(for: quote)) {
                            viewModel.toggleFavorite(quote)
                        }
                    }
                }
                .onDelete { viewModel.delete(at: $0) }
            }
            .overlay {
                if viewModel.quotes.isEmpty {
                    Text("catalog.empty")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationTitle("catalog.title")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isLoading {
                        ProgressView()
                            .accessibilityLabel("catalog.loading")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("catalog.load") {
                        Task { await viewModel.importFromAPI() }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(item: $editedQuote) { quote in
                QuoteFormView(quote: quote) { text, author in
                    try await viewModel.update(quote, text: text, author: author)
                }
            }
            .alert("error.title", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("common.ok", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear { viewModel.load() }
    }
}
