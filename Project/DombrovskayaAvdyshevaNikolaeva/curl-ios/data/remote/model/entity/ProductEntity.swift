import SwiftData
import Foundation

@Model
class ProductEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var productDescription: String
    var tags: [String]
    var imageUrl: String?
    var dateCached: Date
    
    @Relationship(inverse: \FavoriteEntity.product)
    var favorite: FavoriteEntity?
    
    init(id: UUID, name: String, productDescription: String, tags: [String], imageUrl: String?, dateCached: Date = Date()) {
        self.id = id
        self.name = name
        self.productDescription = productDescription
        self.tags = tags
        self.imageUrl = imageUrl
        self.dateCached = dateCached
    }
    
    func toDomain() -> Product {
        return Product(
            id: id,
            name: name,
            description: productDescription,
            tags: tags,
            imageUrlString: imageUrl
        )
    }
}
