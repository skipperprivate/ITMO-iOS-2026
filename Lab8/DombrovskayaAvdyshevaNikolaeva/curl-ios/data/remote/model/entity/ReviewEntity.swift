import SwiftData
import Foundation

@Model
class ReviewEntity {
    @Attribute(.unique) var id: UUID
    var productId: UUID
    var userId: UUID
    var userName: String
    var rating: Int
    var comment: String
    var createdAt: Date
    
    init(id: UUID, productId: UUID, userId: UUID, userName: String, rating: Int, comment: String, createdAt: Date) {
        self.id = id
        self.productId = productId
        self.userId = userId
        self.userName = userName
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
    }
    
    func toDomain() -> Review {
        return Review(
            id: id,
            productId: productId,
            userId: userId,
            userName: userName,
            rating: rating,
            comment: comment,
            createdAt: createdAt
        )
    }
}
