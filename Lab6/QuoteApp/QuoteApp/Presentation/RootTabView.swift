//
//  RootTabView.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import SwiftUI

struct RootTabView: View {
    private let container = DIContainer.shared
    
    var body: some View {
        TabView {
            QuoteOfTheDay(viewModel: container.makeQuoteOfTheDayViewModel())
                .tabItem { Label("Сегодня", systemImage: "quote.bubble") }
            HistoryView(viewModel: container.makeHistoryViewModel())
                .tabItem { Label("История", systemImage: "list.bullet") }
            //FavoritesView(viewModel: FavoritesViewModel())
            //    .tabItem { Label("Избранное", systemImage: "heart.fill") }
            SettingsView(viewModel: container.makeSettingsViewModel())
                .tabItem { Label("Настройки", systemImage: "gearshape") }
        }
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
    }
}
