import Foundation

protocol UserRepository {
    func getUser(id: String) async throws -> UserResponse
    func updateUser(id: String, request: UserRequest) async throws
}
