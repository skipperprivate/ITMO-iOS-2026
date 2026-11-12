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
                    Label("tab.today", systemImage: "sun.max")
                }

            CatalogView()
                .tabItem {
                    Label("tab.catalog", systemImage: "square.grid.2x2")
                }

            FavoritesView()
                .tabItem {
                    Label("tab.favorites", systemImage: "heart")
                }

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gearshape")
                }
        }
        .tint(.indigo)
    }
}
