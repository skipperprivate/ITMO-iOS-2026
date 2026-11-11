@testable import curl_ios
import Foundation

final class MockProductRepository: ProductRepository {

    var productsResult: Result<[Product], Error> = .success([])
    var productByIdResult: Result<Product, Error>?
    var reviewsResult: Result<[Review], Error> = .success([])
    var userFavoritesResult: Result<[Favorite]?, Error> = .success(nil)
    var isFavoriteResult: Result<Bool, Error> = .success(false)

    private(set) var getProductsCallCount = 0
    private(set) var getProductByIdCallCount = 0
    private(set) var getReviewsCallCount = 0
    private(set) var getUserFavoritesCallCount = 0
    private(set) var isFavoriteCallCount = 0
    private(set) var addToFavoritesCallCount = 0
    private(set) var removeFromFavoritesCallCount = 0
    private(set) var addReviewCallCount = 0
    private(set) var updateReviewCallCount = 0
    private(set) var deleteReviewCallCount = 0

    private(set) var lastFetchedProductId: UUID?
    private(set) var lastUserId: UUID?
    private(set) var lastProductId: UUID?
    private(set) var lastReviewId: UUID?
    private(set) var lastMark: Int?
    private(set) var lastReviewText: String?

    func getProducts() async throws -> [Product] {
        getProductsCallCount += 1
        return try productsResult.get()
    }

    func getProductById(_ productId: UUID) async throws -> Product {
        getProductByIdCallCount += 1
        lastFetchedProductId = productId
        guard let result = productByIdResult else {
            throw NSError(domain: "MockProductRepository", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "productByIdResult не задан"])
        }
        return try result.get()
    }

    func getUserFavorites(userId: UUID) async throws -> [Favorite]? {
        getUserFavoritesCallCount += 1
        lastUserId = userId
        return try userFavoritesResult.get()
    }

    func isFavorite(userId: UUID, productId: UUID) async throws -> Bool {
        isFavoriteCallCount += 1
        lastUserId = userId
        lastProductId = productId
        return try isFavoriteResult.get()
    }

    func addToFavorites(userId: UUID, productId: UUID) async throws {
        addToFavoritesCallCount += 1
        lastUserId = userId
        lastProductId = productId
    }

    func removeFromFavorites(userId: UUID, productId: UUID) async throws {
        removeFromFavoritesCallCount += 1
        lastUserId = userId
        lastProductId = productId
    }

    func getReviews(productId: UUID) async throws -> [Review] {
        getReviewsCallCount += 1
        lastFetchedProductId = productId
        return try reviewsResult.get()
    }

    func addReview(userId: UUID, productId: UUID, mark: Int, review: String) async throws {
        addReviewCallCount += 1
        lastUserId = userId
        lastProductId = productId
        lastMark = mark
        lastReviewText = review
    }

    func updateReview(userId: UUID, productId: UUID, reviewId: UUID, mark: Int, review: String) async throws {
        updateReviewCallCount += 1
        lastUserId = userId
        lastProductId = productId
        lastReviewId = reviewId
        lastMark = mark
        lastReviewText = review
    }

    func deleteReview(productId: UUID, reviewId: UUID) async throws {
        deleteReviewCallCount += 1
        lastProductId = productId
        lastReviewId = reviewId
    }
}
