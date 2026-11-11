//
//  RecipeBookApp.swift
//  RecipeBook
//
//  Created by Viktor Medyankin on 23.09.2026.

import SwiftUI
import SwiftData

@main
struct RecipeBookApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: [
                StoredRecipe.self
            ]
        )
    }
}
