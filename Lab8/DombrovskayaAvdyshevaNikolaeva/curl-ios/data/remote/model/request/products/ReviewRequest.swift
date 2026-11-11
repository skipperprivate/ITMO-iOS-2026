import Foundation

struct ReviewRequest: Codable {
    let userId: UUID
    let mark: Int
    let review: String
}
