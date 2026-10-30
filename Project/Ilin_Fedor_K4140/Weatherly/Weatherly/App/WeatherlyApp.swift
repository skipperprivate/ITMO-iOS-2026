//
//  WeatherlyApp.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 20.09.2026.
//

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
