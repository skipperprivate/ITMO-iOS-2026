//
//  QuoteDetailView.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import SwiftUI

struct QuoteDetailView: View {
    let quote: Quote
    let isFavorite: Bool
    let onToggleFavorite: () async -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("\"\(quote.content)\"")
                    .font(.system(size: 26, weight: .medium, design: .serif))
                    .italic()
                
                Text("- \(quote.author)")
                    .font(.title3)
                
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Цитата")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await onToggleFavorite() }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: "\"\(quote.content)\"\n- \(quote.author)")
            }
        }
    }
}
