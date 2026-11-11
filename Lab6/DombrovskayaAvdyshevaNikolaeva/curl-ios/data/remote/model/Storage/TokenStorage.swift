//
//  TokenStorage.swift
//  curl-ios
//  Для UserDefaults лучше сразу сделать небольшую обертку, чтобы не разбрасывать строковые ключи по всему проекту
//  Created by Nadineenik on 02.10.2026.
//

import Foundation

final class TokenStorage {
    // Ключи для Keychain
    private let accessTokenKey = "com.curlylab.accessToken"
    private let refreshTokenKey = "com.curlylab.refreshToken"
    
    private let keychain = KeychainManager.shared
    
    // Сохраняем оба токена (если у вас есть access и refresh)
    func saveTokens(accessToken: String, refreshToken: String) {
        _ = keychain.save(key: accessTokenKey, value: accessToken)
        _ = keychain.save(key: refreshTokenKey, value: refreshToken)
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
