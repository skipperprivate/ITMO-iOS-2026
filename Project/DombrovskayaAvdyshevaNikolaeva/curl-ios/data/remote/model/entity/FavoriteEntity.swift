import Foundation
import SwiftData

@Model
class FavoriteEntity {
    @Attribute(.unique) var productId: UUID
    var userId: UUID
    var dateAdded: Date
    
    var product: ProductEntity?
    
    init(userId: UUID, productId: UUID, dateAdded: Date = Date()) {
        self.userId = userId
        self.productId = productId
        self.dateAdded = dateAdded
    }
}
