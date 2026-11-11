import Foundation

protocol ProductRepository {
    func getProducts() async throws -> [Product]
    func getProductById(_ productId: UUID) async throws -> Product
    
    func getUserFavorites(userId: UUID) async throws -> [Favorite]?
    func isFavorite(userId: UUID, productId: UUID) async throws -> Bool
    func addToFavorites(userId: UUID, productId: UUID) async throws
    func removeFromFavorites(userId: UUID, productId: UUID) async throws
    
    func getReviews(productId: UUID) async throws -> [Review]
    func addReview(userId: UUID, productId: UUID, mark: Int, review: String) async throws
    func updateReview(userId: UUID, productId: UUID, reviewId: UUID, mark: Int, review: String) async throws
    func deleteReview(productId: UUID, reviewId: UUID) async throws
}
