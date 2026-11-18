//
//  GeneratedNumber.swift
//  Lab2
//
//  Created by n grebenkin on 01.10.2026.
//

import Foundation
import SwiftData

@Model
final class GeneratedNumber {
    var value: Int
    var createdAt: Date
    var note: String

    init(value: Int, createdAt: Date = .now, note: String = "") {
        self.value = value
        self.createdAt = createdAt
        self.note = note
    }
}
