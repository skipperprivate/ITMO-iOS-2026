//
//  QuoteAppApp.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import SwiftUI

@main
struct QuoteAppApp: App {
    @StateObject private var theme = DIContainer.shared.themeStore
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(theme.colorScheme)
                .environmentObject(theme)
                .animation(.easeInOut(duration: 0.25), value: theme.isDarkMode)
        }
    }
}
