//
//  Quote.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 24.09.2026.
//

import Foundation

struct Quote: Identifiable, Equatable {
    let id: UUID
    var text: String
    var author: String
    var isFavorite: Bool

    init(id: UUID = UUID(), text: String, author: String, isFavorite: Bool = false) {
        self.id = id
        self.text = text
        self.author = author
        self.isFavorite = isFavorite
    }
}

extension Quote {
    static let preview = Quote(
        text: "Сколько человеку лет, столько человеку и зим.",
        author: "Джейсон Стэтхэм"
    )
}
