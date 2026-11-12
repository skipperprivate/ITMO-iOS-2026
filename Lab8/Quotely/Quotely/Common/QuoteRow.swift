//
//  QuoteRow.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 01.10.2026.
//

import SwiftUI

struct QuoteRow: View {
    let quote: Quote

    @AppStorage(SettingsStorage.Key.showAuthor) private var showAuthor = true

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(quote.text)

            if showAuthor {
                Text(quote.author)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .badge(quote.isFavorite ? "В избранном" : nil)
    }
}
