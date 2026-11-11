//
//  AppSettings.swift
//  RecipeBook
//
//  Created by Viktor Medyankin on 07.10.2026.
//

import Foundation

final class AppSettings {
    
    static let shared = AppSettings()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    
    private enum Keys {
        static let selectedCuisine = "selectedCuisine"
        static let sortOption = "sortOption"
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
    
    
    
    var selectedCuisine: String {
        
        get {
            defaults.string(
                forKey: Keys.selectedCuisine
            ) ?? "Все"
        }
        
        set {
            defaults.set(
                newValue,
                forKey: Keys.selectedCuisine
            )
        }
    }
    
    
    
    var sortOption: String {
        
        get {
            defaults.string(
                forKey: Keys.sortOption
            ) ?? "Название"
        }
        
        set {
            defaults.set(
                newValue,
                forKey: Keys.sortOption
            )
        }
    }
    
    
    
    var hasSeenOnboarding: Bool {
        
        get {
            defaults.bool(
                forKey: Keys.hasSeenOnboarding
            )
        }
        
        set {
            defaults.set(
                newValue,
                forKey: Keys.hasSeenOnboarding
            )
        }
    }
    
    
    
    func resetSettings() {
        
        defaults.removeObject(
            forKey: Keys.selectedCuisine
        )
        
        defaults.removeObject(
            forKey: Keys.sortOption
        )
        
        defaults.removeObject(
            forKey: Keys.hasSeenOnboarding
        )
    }
}
