//
//  QuoteEntity.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 01.10.2026.
//

import Foundation
import SwiftData

@Model
final class QuoteEntity {
    @Attribute(.unique) var id: UUID
    var text: String
    var author: String
    var isFavorite: Bool
    var createdAt: Date
    var remoteID: Int?

    init(
        id: UUID = UUID(),
        text: String,
        author: String,
        isFavorite: Bool = false,
        createdAt: Date = .now,
        remoteID: Int? = nil
    ) {
        self.id = id
        self.text = text
        self.author = author
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.remoteID = remoteID
    }

    func toQuote() -> Quote {
        Quote(id: id, text: text, author: author, isFavorite: isFavorite)
    }
}
