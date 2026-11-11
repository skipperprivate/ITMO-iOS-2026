//
//  User.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

struct User: Identifiable, Hashable {
    let id: String
    let username: String
    let createdAt: Date?
    let imageUrl: URL?
    
    init(id: String, username: String, createdAtString: String, imageUrlString: String?) {
        self.id = id
        self.username = username
        self.createdAt = LocalDateTimeParser.parse(createdAtString)
        self.imageUrl = imageUrlString.flatMap { URL(string: $0) }
    }
}
