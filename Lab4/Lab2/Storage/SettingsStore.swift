//
//  SettingsStore.swift
//  Lab2
//
//  Created by n grebenkin on 01.10.2026.
//

import Foundation

protocol SettingsStore: AnyObject {
    var range: ClosedRange<Int> { get set }
    var savesHistory: Bool { get set }
    func reset()
}

final class UserDefaultsSettingsStore: SettingsStore {
    static let defaultRange = 1...1000

    private enum Key {
        static let minValue = "settings.minValue"
        static let maxValue = "settings.maxValue"
        static let savesHistory = "settings.savesHistory"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.minValue: Self.defaultRange.lowerBound,
            Key.maxValue: Self.defaultRange.upperBound,
            Key.savesHistory: true
        ])
    }

    var range: ClosedRange<Int> {
        get {
            let lower = defaults.integer(forKey: Key.minValue)
            let upper = defaults.integer(forKey: Key.maxValue)
            return lower <= upper ? lower...upper : Self.defaultRange
        }
        set {
            defaults.set(newValue.lowerBound, forKey: Key.minValue)
            defaults.set(newValue.upperBound, forKey: Key.maxValue)
        }
    }

    var savesHistory: Bool {
        get { defaults.bool(forKey: Key.savesHistory) }
        set { defaults.set(newValue, forKey: Key.savesHistory) }
    }

    func reset() {
        [Key.minValue, Key.maxValue, Key.savesHistory].forEach(defaults.removeObject(forKey:))
    }
}
