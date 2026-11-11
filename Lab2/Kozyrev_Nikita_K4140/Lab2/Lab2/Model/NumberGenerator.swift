//
//  NumberGenerator.swift
//  Lab2
//
//  Created by Nikita Kozyrev on 17.09.2026.
//

struct NumberGenerator {
    let range: ClosedRange<Int>

    func next() -> Int {
        .random(in: range)
    }
}
