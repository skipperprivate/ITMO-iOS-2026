import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let generationCount = "generation_count"
        static let lastNumber = "last_number"
        static let isFirstLaunch = "is_first_launch"
    }
    
    var generationCount: Int {
        get { defaults.integer(forKey: Keys.generationCount) }
        set { defaults.set(newValue, forKey: Keys.generationCount) }
    }
    
    var lastNumber: Int {
        get { defaults.integer(forKey: Keys.lastNumber) }
        set { defaults.set(newValue, forKey: Keys.lastNumber) }
    }
    
    var isFirstLaunch: Bool {
        get { defaults.object(forKey: Keys.isFirstLaunch) == nil }
        set { defaults.set(!newValue, forKey: Keys.isFirstLaunch) }
    }
    
    func reset() {
        defaults.removeObject(forKey: Keys.generationCount)
        defaults.removeObject(forKey: Keys.lastNumber)
    }
}
