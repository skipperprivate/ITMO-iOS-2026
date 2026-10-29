import SwiftUI

struct MainTabView: View {

    @AppStorage("appTheme") private var appTheme = "system"

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "house")
                }

            FavoritesView()
                .tabItem {
                    Label("Избранное", systemImage: "heart")
                }

            QuotesView()
                .tabItem {
                    Label("Все цитаты", systemImage: "quote.bubble")
                }

            HistoryView()
                .tabItem {
                    Label("История", systemImage: "clock")
                }

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gear")
                }
        }
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}

#Preview {
    MainTabView()
}
