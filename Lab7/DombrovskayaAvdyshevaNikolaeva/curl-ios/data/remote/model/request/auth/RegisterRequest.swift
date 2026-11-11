//
//  RegisterRequest.swift
//  curl-ios
//
//  Created by Nadineenik on 02.10.2026.
//

import Foundation

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let username: String
}
