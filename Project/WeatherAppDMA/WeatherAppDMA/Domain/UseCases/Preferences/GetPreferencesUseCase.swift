import Foundation

protocol GetPreferencesUseCase: Sendable {
    func execute() -> UserPreferences
}

struct DefaultGetPreferencesUseCase: GetPreferencesUseCase {
    let repository: PreferencesRepository

    func execute() -> UserPreferences {
        repository.get()
    }
}
