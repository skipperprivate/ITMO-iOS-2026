//
//  Review.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

struct Review: Identifiable, Hashable {
    let id: UUID
    let productId: UUID
    let userId: UUID
    let userName: String
    let rating: Int
    let comment: String
    let createdAt: Date // В домене используем Date, а не String
}
