//
//  Quote.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import Foundation

struct Quote: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let content: String
    let author: String
}
