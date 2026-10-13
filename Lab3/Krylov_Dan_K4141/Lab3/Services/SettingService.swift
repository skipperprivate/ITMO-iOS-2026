import Foundation

final class SettingsService {
    private let defaults = UserDefaults.standard
    private let maxValueKey = "maxValue"

    func loadMaxValue() -> Int {
        let value = defaults.integer(forKey: maxValueKey)
        return value == 0 ? 100 : value
    }

    func saveMaxValue(_ value: Int) {
        defaults.set(value, forKey: maxValueKey)
    }
}
