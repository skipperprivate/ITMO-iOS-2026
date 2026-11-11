//
//  Product.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let tags: [String]
    let imageUrl: URL? // В домене используем URL, а не String
    
    // Статический метод для удобной конвертации из String в URL
    init(id: UUID, name: String, description: String, tags: [String], imageUrlString: String?) {
        self.id = id
        self.name = name
        self.description = description
        self.tags = tags
        self.imageUrl = imageUrlString.flatMap { URL(string: $0) }
    }
}
