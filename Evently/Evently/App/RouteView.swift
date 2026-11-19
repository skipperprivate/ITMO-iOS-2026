import SwiftUI

struct RootView: View {
    let container: AppContainer

    @AppStorage(AppStorageKeys.hasCompletedOnboarding)
    private var hasCompletedOnboarding = false

    @State private var didFinishTestOnboarding = false

    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-ui-testing")
    }

    private var forceOnboarding: Bool {
        ProcessInfo.processInfo.arguments.contains("-ui-testing-onboarding")
    }

    private var shouldShowOnboarding: Bool {
        if isUITesting {
            return forceOnboarding && !didFinishTestOnboarding
        }
        return !hasCompletedOnboarding
    }

    var body: some View {
        if shouldShowOnboarding {
            OnboardingView {
                if isUITesting {
                    didFinishTestOnboarding = true
                } else {
                    hasCompletedOnboarding = true
                }
            }
        } else {
            MainTabView(container: container)
        }
    }
}
