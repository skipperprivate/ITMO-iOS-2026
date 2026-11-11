@testable import curl_ios
import Foundation


final class MockProductRepository: ProductRepository {
    func toggleFavorite(userId: UUID, productId: UUID) async throws {
        // заглушка
    }
    
    var productsResult: Result<[Product], Error> = .success([])
    var reviewsResult: Result<[Review], Error> = .success([])

    private(set) var fetchProductsCallCount = 0
    private(set) var fetchReviewsCallCount = 0
    private(set) var lastFetchedProductId: UUID?

    func fetchProducts() async throws -> [Product] {
        fetchProductsCallCount += 1
        return try productsResult.get()
    }

    func fetchReviews(productId: UUID) async throws -> [Review] {
        fetchReviewsCallCount += 1
        lastFetchedProductId = productId
        return try reviewsResult.get()
    }
}
