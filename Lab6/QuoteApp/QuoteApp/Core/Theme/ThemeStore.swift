//
//  ThemeStore.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 17.10.2026.
//

import SwiftUI
import Combine

@MainActor
final class ThemeStore: ObservableObject {
    private let key = "settings.isDarkMode"
    private let defaults: UserDefaults
    
    @Published var isDarkMode: Bool {
        didSet {
            guard oldValue != isDarkMode else { return }
            defaults.set(isDarkMode, forKey: key)
        }
    }

    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isDarkMode = defaults.bool(forKey: key)
    }
    
    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }
}
