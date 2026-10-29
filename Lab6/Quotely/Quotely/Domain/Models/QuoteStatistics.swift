//
//  QuoteStatistics.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 08.10.2026.
//

import Foundation

nonisolated struct QuoteStatistics {
    let total: Int
    let favorites: Int
    let authors: Int
    let averageLength: Int

    static let empty = QuoteStatistics(total: 0, favorites: 0, authors: 0, averageLength: 0)

    @concurrent
    static func calculate(for quotes: [Quote]) async -> QuoteStatistics {
        guard !quotes.isEmpty else { return .empty }

        return QuoteStatistics(
            total: quotes.count,
            favorites: quotes.filter { $0.isFavorite }.count,
            authors: Set(quotes.map { $0.author }).count,
            averageLength: quotes.reduce(0) { $0 + $1.text.count } / quotes.count
        )
    }
}
