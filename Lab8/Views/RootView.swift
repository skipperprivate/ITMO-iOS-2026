import SwiftUI

struct RootView: View {
    @StateObject private var myPosts = MyPostsViewModel()
    @AppStorage("appTheme") private var theme = "system"

    private var colorScheme: ColorScheme? {
        switch theme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }

    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Новости", systemImage: "newspaper")
                }

            MyPostsView()
                .tabItem {
                    Label("Мои посты", systemImage: "doc.text")
                }

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape")
                }
        }
        .environmentObject(myPosts)
        .preferredColorScheme(colorScheme)
    }
}