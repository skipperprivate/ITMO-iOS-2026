//
//  Word.swift
//  curl-ios
//
//  Created by Nadineenik on 12.10.2026.
//

import Foundation

struct Word: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
}
