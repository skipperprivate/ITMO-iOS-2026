//
//  RootView.swift
//  MenuPlanner
//
//  Created by FergeS on 31/10/2026.
//
import SwiftData
import SwiftUI

struct RootView: View {
    let userSettings: UserSettings

    var body: some View {
        if userSettings.hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView(viewModel: OnboardingViewModel(userSettings: userSettings))
        }
    }
}

#Preview("Обучение") {
    let defaults = UserDefaults(
        suiteName: "MenuPlanner.Preview.Onboarding"
    )!

    let settings = UserSettings(defaults: defaults)
    settings.hasCompletedOnboarding = false

    return RootView(userSettings: settings)
        .modelContainer(for: AppSchema.models, inMemory: true)
}
#Preview("Основной экран") {
    let defaults = UserDefaults(
        suiteName: "MenuPlanner.Preview.Main"
    )!

    let settings = UserSettings(defaults: defaults)
    settings.hasCompletedOnboarding = true

    return RootView(userSettings: settings)
        .modelContainer(for: AppSchema.models, inMemory: true)
}
