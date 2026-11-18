//
//  NumberGeneratorModel.swift
//  Lab2
//
//  Created by n grebenkin on 24.09.2026.
//

protocol NumberGeneratorService {
    func generate(in range: ClosedRange<Int>) -> Int
}

struct RandomNumberGeneratorService: NumberGeneratorService {
    func generate(in range: ClosedRange<Int>) -> Int {
        Int.random(in: range)
    }
}
