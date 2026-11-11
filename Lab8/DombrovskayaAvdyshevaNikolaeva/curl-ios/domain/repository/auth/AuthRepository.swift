import Foundation

protocol AuthRepository {
    func register(email: String, password: String, username: String) async throws -> AuthResponse
    func login(email: String, password: String) async throws -> AuthResponse
    func isUserLoggedIn() async -> Bool
    func logout() async
    func getAccessToken() async -> String?
    func getUserId() async -> String?
}
