//
//  UserDefualts.swift
//  Lab1
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import Foundation

class UserDefaultsService {
    static let shared = UserDefaultsService()
    
    private let defaults = UserDefaults.standard
    private let lastNumberKey = "lastRandomNumber"
    
    var lastRandomNumber: Int? {
        get {
            guard defaults.object(forKey: lastNumberKey) != nil else { return nil }
            return defaults.integer(forKey: lastNumberKey)
        }
        set {
            if let value = newValue {
                defaults.set(value, forKey: lastNumberKey)
            } else {
                defaults.removeObject(forKey: lastNumberKey)
            }
        }
    }
}
