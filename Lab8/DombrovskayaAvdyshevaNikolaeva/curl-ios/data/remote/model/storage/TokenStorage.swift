import Foundation

final class TokenStorage {
    private let accessTokenKey = "com.curlylab.accessToken"
    private let refreshTokenKey = "com.curlylab.refreshToken"
    
    private let keychain = KeychainManager.shared
    
    func saveTokens(accessToken: String?, refreshToken: String?) {
        if let accessToken {
            _ = keychain.save(key: accessTokenKey, value: accessToken)
        }
        if let refreshToken {
            _ = keychain.save(key: refreshTokenKey, value: refreshToken)
        }
    }
    
    func getAccessToken() -> String? {
        return keychain.read(key: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return keychain.read(key: refreshTokenKey)
    }
    
    func clearTokens() {
        _ = keychain.delete(key: accessTokenKey)
        _ = keychain.delete(key: refreshTokenKey)
    }
}
