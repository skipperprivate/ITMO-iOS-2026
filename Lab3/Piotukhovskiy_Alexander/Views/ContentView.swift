import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CurrentWeatherView()
                .tabItem { Label("Now", systemImage: "sun.max") }
        }
    }
}
