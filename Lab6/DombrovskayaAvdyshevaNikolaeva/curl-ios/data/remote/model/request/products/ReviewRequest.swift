//
//  ReviewRequest.swift
//  curl-ios
//
//  Created by Nadineenik on 02.10.2026.
//

import Foundation

struct ReviewRequest: Codable {
    let userId: UUID
    let mark: Int
    let review: String
}
