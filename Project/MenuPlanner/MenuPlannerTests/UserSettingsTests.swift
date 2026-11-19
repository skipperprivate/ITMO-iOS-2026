import XCTest
@testable import MenuPlanner

@MainActor
final class UserSettingsTests: XCTestCase {
    func testNewSettingsHaveNoOnboardingOrProfile() throws {
        try withDefaults { defaults in
            let settings = UserSettings(defaults: defaults)
            XCTAssertFalse(settings.hasCompletedOnboarding)
            XCTAssertEqual(settings.userName, "")
            XCTAssertNil(settings.birthDate)
        }
    }

    func testCompletingOnboardingPersistsAcrossSettingsInstances() throws {
        try withDefaults { defaults in
            let settings = UserSettings(defaults: defaults)
            OnboardingViewModel(userSettings: settings).completeOnboarding()
            XCTAssertTrue(settings.hasCompletedOnboarding)
            XCTAssertTrue(UserSettings(defaults: defaults).hasCompletedOnboarding)
        }
    }

    func testProfilePersistsAndClearingBirthDateRemovesStoredValue() throws {
        try withDefaults { defaults in
            let settings = UserSettings(defaults: defaults)
            let birthday = Date(timeIntervalSince1970: 1_000_000)
            settings.userName = "Саша"
            settings.birthDate = birthday
            let reloaded = UserSettings(defaults: defaults)
            XCTAssertEqual(reloaded.userName, "Саша")
            XCTAssertEqual(reloaded.birthDate, birthday)
            reloaded.birthDate = nil
            XCTAssertNil(UserSettings(defaults: defaults).birthDate)
        }
    }

    private func withDefaults(_ body: (UserDefaults) throws -> Void) throws {
        let suite = "MenuPlanner.UnitTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try body(defaults)
    }
}
