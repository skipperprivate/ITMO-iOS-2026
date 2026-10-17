//
//  QuoteDTO.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import Foundation

struct QuoteDTO: Decodable {
    let id: Int
    let quote: String
    let author: String
    
    func toDomain() -> Quote {
        Quote(id: id, content: quote, author: author)
    }
}

struct QuoteListDTO: Decodable {
    let quotes: [QuoteDTO]
    let total: Int
    let offset: Int
    let limit: Int
    
    enum CodingKeys: String, CodingKey {
        case quotes
        case total
        case limit
        case offset = "skip"
    }
}
