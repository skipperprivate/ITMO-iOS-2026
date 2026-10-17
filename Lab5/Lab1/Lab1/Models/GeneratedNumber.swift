//
//  GeneratedNumber.swift
//  Lab1
//
//  Created by Кирилл Матвеев on 24.09.2026.
//

import Foundation

struct GeneratedNumber {
    var value: Int?
    
    mutating func generate() {
        value = Int.random(in: 1...100)
    }
}
