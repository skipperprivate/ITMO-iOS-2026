//
//  FavoriteEntity.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation
import SwiftData

@Model
class FavoriteEntity {
    @Attribute(.unique) var productId: UUID
    var userId: UUID
    var dateAdded: Date
    
    // Связь с локальной сущностью продукта (если вы кэшируете продукты)
    var product: ProductEntity?
    
    init(userId: UUID, productId: UUID, dateAdded: Date = Date()) {
        self.userId = userId
        self.productId = productId
        self.dateAdded = dateAdded
    }
}
