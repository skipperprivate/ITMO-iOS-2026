//
//  UserResponse.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

struct UserResponse: Codable {
    let id: String
    let username: String
    let createdAt: String // LocalDateTime приходит как строка в ISO формате
    let imageUrl: String?
}

extension UserResponse {
    func toDomain() -> User {
        return User(
            id: id,
            username: username,
            createdAtString: createdAt,
            imageUrlString: imageUrl
        )
    }
}
