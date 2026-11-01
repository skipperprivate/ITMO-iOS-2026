//
//  RecipeBoxApp.swift
//  RecipeBox
//
//  Created by Nikita Makhov on 15.10.2026.
//

import SwiftUI
import SwiftData

@main
struct RecipeBoxApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoriteRecipe.self,
            UserRecipe.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
