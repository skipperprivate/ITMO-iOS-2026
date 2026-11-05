//
//  FavoritesView.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favorites.isEmpty {
                    EmptyStateView(title: "Нет избранного", systemImage: "heart.slash", description: "Добавьте цитаты с главного экрана")
                } else {
                    List {
                        ForEach(viewModel.favorites) { quote in
                            NavigationLink {
                                QuoteDetailView(quote: quote, isFavorite: true)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(quote.content).lineLimit(2)
                                    Text("- \(quote.author)").font(.caption).foregroundColor(.secondary)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.remove(quote)
                                    }
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Избранное")
            .onAppear {  }
        }
    }
}
