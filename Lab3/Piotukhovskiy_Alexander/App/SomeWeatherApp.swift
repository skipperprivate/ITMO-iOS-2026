import SwiftUI

@main
struct SomeWeatherApp: App {
    @StateObject private var weather = WeatherViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(weather)
        }
    }
}
