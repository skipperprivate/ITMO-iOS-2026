import Foundation

@MainActor
final class UserRepositoryImpl: UserRepository {
    private let apiService = ApiService.shared
    private let authManager = AuthManager.shared
    
    func getUser(id: String) async throws -> UserResponse {
        let response: UserResponse = try await apiService.get("/users/\(id)")
        return response
    }
    
    func updateUser(id: String, request: UserRequest) async throws {
        let _: EmptyResponse = try await apiService.post("/users/\(id)", body: request)
    }
}
