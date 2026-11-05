//
//  UserDefaults.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import Foundation

protocol StorageServiceProtocol {
    func save<T: Codable>(_ value: T, forKey key: String)
    func load<T: Codable>(forKey key: String, as type: T.Type) -> T?
    func remove(forKey key: String)
}

final class UserDefaultsStorageService: StorageServiceProtocol {
    private let defaults: UserDefaults
    private let queue = DispatchQueue(label: "storage.userdefaults.queue", qos: .utility)
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func save<T: Codable>(_ value: T, forKey key: String) {
        queue.sync {
            guard let data = try? JSONEncoder().encode(value) else { return }
            defaults.set(data, forKey: key)
        }
    }
    
    func load<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        queue.sync {
            guard let data = defaults.data(forKey: key) else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
    }
    
    func remove(forKey key: String) {
        queue.sync {
            defaults.removeObject(forKey: key)
        }
    }
}
