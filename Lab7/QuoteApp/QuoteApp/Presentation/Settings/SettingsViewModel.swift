//
//  SettingsViewModel.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    private let defaults: UserDefaults
    
    private enum Keys {
        static let theme = "settings.theme"
    }
    
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
}
