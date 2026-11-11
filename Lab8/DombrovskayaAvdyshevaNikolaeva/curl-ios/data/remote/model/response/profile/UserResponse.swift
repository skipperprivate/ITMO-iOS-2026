import Foundation

struct UserResponse: Codable {
    let id: String
    let username: String
    let createdAt: String
    let imageUrl: String?
}

extension UserResponse {
    func toDomain() -> User {
        return User(
            id: id,
            username: username,
            createdAtString: createdAt,
            imageUrlString: imageUrl
        )
    }
}
