//
//  SettingsStorage.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 01.10.2026.
//

import Foundation

final class SettingsStorage {
    static let shared = SettingsStorage()

    enum Key {
        static let showAuthor = "showAuthor"
        static let dailyQuoteID = "dailyQuoteID"
        static let dailyQuoteDate = "dailyQuoteDate"
        static let importSkip = "importSkip"
    }

    private let defaults = UserDefaults.standard

    var showAuthor: Bool {
        get { defaults.object(forKey: Key.showAuthor) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.showAuthor) }
    }

    var dailyQuoteID: UUID? {
        get {
            guard let value = defaults.string(forKey: Key.dailyQuoteID) else { return nil }
            return UUID(uuidString: value)
        }
        set { defaults.set(newValue?.uuidString, forKey: Key.dailyQuoteID) }
    }

    var dailyQuoteDate: Date? {
        get { defaults.object(forKey: Key.dailyQuoteDate) as? Date }
        set { defaults.set(newValue, forKey: Key.dailyQuoteDate) }
    }

    var importSkip: Int {
        get { defaults.integer(forKey: Key.importSkip) }
        set { defaults.set(newValue, forKey: Key.importSkip) }
    }

    func reset() {
        defaults.removeObject(forKey: Key.showAuthor)
        defaults.removeObject(forKey: Key.dailyQuoteID)
        defaults.removeObject(forKey: Key.dailyQuoteDate)
        defaults.removeObject(forKey: Key.importSkip)
    }
}
