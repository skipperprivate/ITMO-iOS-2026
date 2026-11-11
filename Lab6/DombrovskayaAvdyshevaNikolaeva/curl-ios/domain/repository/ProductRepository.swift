import Foundation

protocol ProductRepository {
    func fetchProducts() async throws -> [Product]
    func fetchReviews(productId: UUID) async throws -> [Review]
    func toggleFavorite(userId: UUID, productId: UUID) async throws
}
