//
//  OnboardingViewModel.swift
//  MenuPlanner
//
//  Created by FergeS on 31/10/2026.
//
import SwiftUI

@MainActor
final class OnboardingViewModel {
    private let userSettings: UserSettings
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }
    
    func completeOnboarding() {
        userSettings.hasCompletedOnboarding = true
    }
}
