import Foundation

struct AuthResponse: Codable {
    let access: String
    let refresh: String
    let userId: String?
    let email: String?
    let username: String?
}
