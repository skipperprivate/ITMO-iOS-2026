//
//  GeneratorViewModel.swift
//  Lab2
//
//  Created by Nikita Kozyrev on 17.09.2026.
//

import Observation

@Observable
final class GeneratorViewModel {
    private(set) var currentValue: Int?

    @ObservationIgnored
    private let generator: NumberGenerator

    init(generator: NumberGenerator = NumberGenerator(range: 1...1000)) {
        self.generator = generator
    }

    var displayText: String {
        currentValue.map(String.init) ?? "—"
    }

    func roll() {
        currentValue = generator.next()
    }
}
