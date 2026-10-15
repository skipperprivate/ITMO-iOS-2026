//
//  RandomNumberModel.swift
//  lab3
//
//  Created by Siobko Boris on 24.09.2026.
//

struct RandomNumberModel {
    func generate() -> Int {
        return Int.random(in: 1...100)
    }
}
