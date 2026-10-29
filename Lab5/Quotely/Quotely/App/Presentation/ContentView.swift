//
//  ContentView.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 24.09.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Сегодня", systemImage: "sun.max")
                }

            CatalogView()
                .tabItem {
                    Label("Каталог", systemImage: "square.grid.2x2")
                }

            FavoritesView()
                .tabItem {
                    Label("Избранное", systemImage: "heart")
                }

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape")
                }
        }
    }
}
