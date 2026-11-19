//
//  UserDefaults.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import Foundation
import Observation

@MainActor
@Observable
final class UserSettings {
    private let defaults: UserDefaults

    private enum Key {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let userName = "userName"
        static let birthDate = "birthDate"
    }

    var hasCompletedOnboarding: Bool {
        didSet {
            defaults.set (hasCompletedOnboarding, forKey: Key.hasCompletedOnboarding)
        }
    }

    var userName: String {
        didSet {
            defaults.set (userName, forKey: Key.userName)
        }
    }

    var birthDate: Date? {
        didSet {
            if let birthDate {
                defaults.set (birthDate, forKey: Key.birthDate)
            } else {
                defaults.removeObject (forKey: Key.birthDate)
            }
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        self.hasCompletedOnboarding = defaults.bool (forKey: Key.hasCompletedOnboarding)
        self.userName = defaults.string (forKey: Key.userName) ?? ""
        self.birthDate = defaults.object(forKey: Key.birthDate) as? Date
    }
}
