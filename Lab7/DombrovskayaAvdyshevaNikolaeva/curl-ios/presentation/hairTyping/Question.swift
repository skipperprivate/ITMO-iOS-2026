//
//  Question.swift
//  curl-ios
//
//  Created by Nadineenik on 19.10.2026.
//

import Foundation

struct Question: Identifiable {
    let id = UUID()
    let topic: String
    var answers: [Answer]
    var selectedIndex: Int? = nil
}

