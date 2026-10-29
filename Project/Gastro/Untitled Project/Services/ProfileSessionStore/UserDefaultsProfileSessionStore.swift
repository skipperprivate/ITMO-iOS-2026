import Foundation

enum ProfileSessionError: LocalizedError {
    case emptyName
    case emptyPassword

    var errorDescription: String? {
        switch self {
            case .emptyName: "Enter your name"
            case .emptyPassword: "Enter a password"
        }
    }
}

@MainActor
final class UserDefaultsProfileSessionStore: ProfileSessionStore {
    private enum Keys {
        static let isLoggedIn = "profile.isLoggedIn"
        static let username = "profile.username"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var currentUsername: String? {
        guard defaults.bool(forKey: Keys.isLoggedIn),
            let name = defaults.string(forKey: Keys.username),
            !name.isEmpty
        else { return nil }
        return name
    }

    func signIn(name: String, password: String) throws {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedName.isEmpty else { throw ProfileSessionError.emptyName }
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ProfileSessionError.emptyPassword
        }
        defaults.set(normalizedName, forKey: Keys.username)
        defaults.set(true, forKey: Keys.isLoggedIn)
    }

    func signOut() {
        defaults.set(false, forKey: Keys.isLoggedIn)
        defaults.removeObject(forKey: Keys.username)
    }
}
