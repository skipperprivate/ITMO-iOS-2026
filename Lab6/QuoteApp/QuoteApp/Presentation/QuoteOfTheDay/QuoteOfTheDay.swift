//
//  QuoteOfTheDay.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import SwiftUI

struct QuoteOfTheDay: View {
    @StateObject private var viewModel: QuoteOfTheDayViewModel
    
    init(viewModel: QuoteOfTheDayViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                content
                    .padding(24)
            }
            .navigationTitle("Цитата дня")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.quote == nil {
            ProgressView("Загрузка...")
        } else if let quote = viewModel.quote {
            quoteCard(quote)
        } else if let error = viewModel.errorMessage {
            errorView(error)
        }
    }
    
    private func quoteCard(_ quote: Quote) -> some View {
        VStack(spacing: 28) {
            Text("\"\(quote.content)\"")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .italic()
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .id(quote.id)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            
            Text("- \(quote.author)")
                .font(.headline)
            
            actionBar
        }
    }
    
    private var actionBar: some View {
        HStack(spacing: 32) {
            Button {
                
            } label: {
                Image(systemName: "heart")
            }
            
            ShareLink(item: viewModel.shareText) {
                Image(systemName: "square.and.arrow.up")
            }
            
            Button {
                Task {
                    await viewModel.load()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .padding(.top, 8)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
            Text(error).multilineTextAlignment(.center)
            Button("Повторить") { Task { await viewModel.load() }}
        }
    }
}

struct QuoteOfTheDay_Previews: PreviewProvider {
    static var previews: some View {
        QuoteOfTheDay(viewModel: DIContainer.shared.makeQuoteOfTheDayViewModel())
    }
}
