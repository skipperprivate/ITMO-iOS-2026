import Foundation

struct Review: Identifiable, Hashable {
    let id: UUID
    let productId: UUID
    let userId: UUID
    let userName: String
    let rating: Int
    let comment: String
    let createdAt: Date
}
