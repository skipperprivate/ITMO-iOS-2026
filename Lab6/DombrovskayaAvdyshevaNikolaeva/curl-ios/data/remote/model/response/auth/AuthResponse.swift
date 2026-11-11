//
//  AuthResponse.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

struct AuthResponse: Codable {
    let access: String
    let refresh: String
    let userId: String?
    let email: String?
    let username: String?
}


//struct AuthResponse: Codable {
//    let accessToken: String
//    let refreshToken: String
//    let userId: String?
//    let email: String?
//    let username: String?
//
//    enum CodingKeys: String, CodingKey {
//        case accessToken = "access"
//        case refreshToken = "refresh"
//        case  userId, email, username
//    }
//}
