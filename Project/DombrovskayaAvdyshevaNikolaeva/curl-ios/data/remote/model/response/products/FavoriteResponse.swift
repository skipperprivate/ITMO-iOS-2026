import Foundation

struct FavoriteResponse: Codable {
    let userId: UUID
    let productId: UUID
}

extension FavoriteResponse {
    func toDomain(product: Product? = nil) -> Favorite {
        return Favorite(
            userId: userId,
            productId: productId,
            product: product
        )
    }
}
