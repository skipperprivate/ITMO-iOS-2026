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
        HStack(alignment: .top, spacing: 12) {
            if quote.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(quote.text)
                    .font(.body.weight(.medium))

                if showAuthor {
                    Text(quote.author)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .badge(quote.isFavorite ? String(localized: "quote.favorite") : nil)
    }
}
