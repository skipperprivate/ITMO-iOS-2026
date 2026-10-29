//
//  Quote.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 24.09.2026.
//

import Foundation

struct Quote {
    let text: String
    let author: String
}

extension Quote {
    static let preview = Quote(
        text: "Сколько человеку лет, столько человеку и зим.",
        author: "Джейсон Стэтхэм"
    )
}
