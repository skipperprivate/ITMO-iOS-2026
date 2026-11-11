//
//  Favorite.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

// Доменная модель
struct Favorite {
    let userId: UUID
    let productId: UUID
    let product: Product? // Ссылка на другую доменную модель
}
