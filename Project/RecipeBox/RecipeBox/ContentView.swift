//
//  ContentView.swift
//  RecipeBox
//
//  Created by Nikita Makhov on 15.10.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                        .accessibilityLabel("Главная")
                }

            BrowseView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                        .accessibilityLabel("Рецепты")
                }

            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                        .accessibilityLabel("Понравившиеся")
                }

            MyRecipesView()
                .tabItem {
                    Image(systemName: "book")
                        .accessibilityLabel("Мои рецепты")
                }
        }
    }
}
