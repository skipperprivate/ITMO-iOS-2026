//
//  FavoriteProductEntity.swift
//  curl-ios
//
//  Created by Nadineenik on 02.10.2026.
//

import SwiftData
import Foundation

@Model
class FavoriteProductEntity {
    @Attribute(.unique) var productId: UUID
    var name: String
    var imageUrl: String?
    var dateAdded: Date
    
    init(productId: UUID, name: String, imageUrl: String? = nil, dateAdded: Date = Date()) {
        self.productId = productId
        self.name = name
        self.imageUrl = imageUrl
        self.dateAdded = dateAdded
    }
}
