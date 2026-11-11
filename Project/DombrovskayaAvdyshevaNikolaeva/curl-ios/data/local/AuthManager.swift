import Foundation
import Combine

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    private let tokenStorage: TokenStorage
    private let userDefaults: UserDefaults
    
    private enum Keys {
        static let isLoggedIn = "is_logged_in"
        static let userId = "user_id"
        static let email = "email"
        static let username = "username"
    }
    
    @Published private(set) var isLoggedIn: Bool
    
    private init(
        tokenStorage: TokenStorage = TokenStorage(),
        userDefaults: UserDefaults = .standard
    ) {
        self.tokenStorage = tokenStorage
        self.userDefaults = userDefaults
        self.isLoggedIn = userDefaults.bool(forKey: Keys.isLoggedIn)
    }
    
    var hasValidSession: Bool {
        isLoggedIn
        && tokenStorage.getAccessToken() != nil
        && tokenStorage.getRefreshToken() != nil
    }
    
    func saveAuthData(
        isLoggedIn: Bool,
        accessToken: String? = nil,
        refreshToken: String? = nil,
        userId: String? = nil,
        username: String? = nil,
        email: String? = nil
    ) {
        userDefaults.set(isLoggedIn, forKey: Keys.isLoggedIn)
        if let userId { userDefaults.set(userId, forKey: Keys.userId)}
        if let email { userDefaults.set(email, forKey: Keys.email)}
        if let username { userDefaults.set(username, forKey: Keys.username)}
        
        tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        
        self.isLoggedIn = isLoggedIn
    }
    
    func getUserId() -> String? {
        userDefaults.string(forKey: Keys.userId)
    }
    
    func getEmail() -> String? {
        userDefaults.string(forKey: Keys.email)
    }
    
    func getUsername() -> String? {
        userDefaults.string(forKey: Keys.username)
    }
    
    func getAccessToken() -> String? {
        tokenStorage.getAccessToken()
    }
    
    func getRefreshToken() -> String? {
        tokenStorage.getRefreshToken()
    }
    
    func clearAuthData() {
        userDefaults.removeObject(forKey: Keys.isLoggedIn)
        userDefaults.removeObject(forKey: Keys.userId)
        userDefaults.removeObject(forKey: Keys.email)
        userDefaults.removeObject(forKey: Keys.username)
        
        tokenStorage.clearTokens()
        
        self.isLoggedIn = false
    }
}
