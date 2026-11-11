//
//  ContentView.swift
//  RecipeBook
//
//  Created by Viktor Medyankin on 23.09.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        let repository = RecipeRepository(api: RecipeAPI(), context: context)
        
        TabView {
            NavigationStack { HomeView(repository: repository) }
                .tabItem { Label("Главная", systemImage: "house.fill") }
            
            NavigationStack { CategoriesView(repository: repository) }
                .tabItem { Label("Категории", systemImage: "square.grid.2x2.fill") }
            
            NavigationStack { FavoritesView(repository: repository) }
                .tabItem { Label("Избранное", systemImage: "heart.fill") }
            
            NavigationStack { AboutView() }
                .tabItem { Label("О приложении", systemImage: "info.circle.fill") }
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    ContentView()
}
