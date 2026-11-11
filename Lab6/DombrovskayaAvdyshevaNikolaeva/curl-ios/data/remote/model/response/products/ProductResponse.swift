//
//  ProductResponse.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

struct ProductResponse: Codable {
    let id: UUID
    let name: String
    let description: String
    let tags: [String]
    let imageUrl: String?
}

extension ProductResponse {
    func toDomain() -> Product {
        return Product(
            id: id,
            name: name,
            description: description,
            tags: tags,
            imageUrlString: imageUrl
        )
    }
}
