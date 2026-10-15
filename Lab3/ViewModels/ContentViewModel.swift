//
//  ContentViewModel.swift
//  lab3
//
//  Created by Siobko Boris on 24.09.2026.
//

import Combine

class ContentViewModel: ObservableObject {
    @Published private(set) var randomNumber = 0

    private let model = RandomNumberModel()

    func generateNumber() {
        randomNumber = model.generate()
    }
}
