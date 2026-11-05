//
//  QuoteListView.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import SwiftUI

struct QuoteListView: View {
    @StateObject private var viewModel: QuoteListViewModel
    
    init(viewModel: QuoteListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.quotes.isEmpty && viewModel.isLoading {
                    ProgressView("Загрузка...")
                } else if viewModel.quotes.isEmpty, let error = viewModel.errorMessage {
                    EmptyStateView(
                        title: "Ошибка загрузки",
                        systemImage: "exclamationmark.triangle",
                        description: error,
                        actionTitle: "Повторить",
                        action: { Task { await viewModel.loadInitial() } })
                } else {
                    listContent
                }
            }
            .navigationTitle("Список цитат")
            .task { await viewModel.loadInitial() }
        }
    }
    
    private var listContent: some View {
        List {
            ForEach(viewModel.quotes) { quote in
                NavigationLink {
                    QuoteDetailView(
                        quote: quote,
                        isFavorite: viewModel.isFavorite(quote),
                        onToggleFavorite: { await viewModel.toggleFavorite(quote: quote) }
                    )
                } label: {
                    QuoteRow(quote: quote, isFavorite: viewModel.isFavorite(quote))
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .task {
                    await viewModel.loadMoreIfNeedeed(currentItem: quote)
                }
            }
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain).refreshable {
            await viewModel.loadInitial()
        }
    }
    
    private struct QuoteRow: View {
        let quote: Quote
        let isFavorite: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(quote.content)
                    .lineLimit(2)
                Text("- \(quote.author)")
            }
            .padding(.vertical, 4)
        }
    }
}
