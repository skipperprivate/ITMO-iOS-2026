//
//  ReviewResponse.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

struct ReviewResponse: Codable {
    let reviewId: UUID
    let userId: UUID
    let productId: UUID
    let date: String
    let mark: Int
    let review: String
}

extension ReviewResponse {
    func toDomain(userName: String) -> Review {
        return Review(
            id: reviewId,
            productId: productId,
            userId: userId,
            userName: userName,
            rating: mark,
            comment: review,
            createdAt: DateParser.parse(date)
        )
    }
}
