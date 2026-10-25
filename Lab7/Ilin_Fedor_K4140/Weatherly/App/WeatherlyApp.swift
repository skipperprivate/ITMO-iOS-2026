import SwiftUI

@main
struct WeatherlyApp: App {
    private let container = AppContainer.configuredForLaunch()

    init() {
        AppFont.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}
