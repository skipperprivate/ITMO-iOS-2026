//
//  MenuPlannerApp.swift
//  MenuPlanner
//
//  Created by FergeS on 21.10.2026.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct MenuPlannerApp: App {
    @State private var userSettings: UserSettings
    private let container: ModelContainer
    private let appDefaults: UserDefaults
    #if DEBUG
    private let isUITesting: Bool
    #endif

    init() {
        var defaults = UserDefaults.standard
        var inMemory = false
        #if DEBUG
        // Each UI test gets its own settings; relaunching within a test retains onboarding.
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") {
            let testID = ProcessInfo.processInfo.environment["MENU_PLANNER_TEST_ID"] ?? "default"
            defaults = UserDefaults(suiteName: "MenuPlanner.UITests.\(testID)")!
            inMemory = true
            UIView.setAnimationsEnabled(false)
            if ProcessInfo.processInfo.arguments.contains("--skip-onboarding") {
                defaults.set(true, forKey: "hasCompletedOnboarding")
            }
        }
        isUITesting = inMemory
        #endif
        appDefaults = defaults
        _userSettings = State(initialValue: UserSettings(defaults: defaults))
        do {
            container = try ModelContainer(
                for: Schema(AppSchema.models),
                configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory)
            )
        } catch {
            fatalError("Не удалось открыть хранилище: \(error)")
        }
    }
    
    var body: some Scene {        
        WindowGroup {
            RootView(userSettings: userSettings)
                .defaultAppStorage(appDefaults)
                #if DEBUG
                .transaction { transaction in
                    if isUITesting { transaction.disablesAnimations = true }
                }
                #endif
        }.modelContainer(container)
    }
}
