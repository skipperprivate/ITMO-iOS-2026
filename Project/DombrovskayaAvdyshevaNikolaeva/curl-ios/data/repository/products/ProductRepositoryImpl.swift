import Foundation

final class ProductRepositoryImpl: ProductRepository {
    private let apiClient: ApiService
    
    init(apiClient: ApiService = .shared) {
        self.apiClient = apiClient
    }
    
    func getProducts() async throws -> [Product] {
        let responses: [ProductResponse] = try await apiClient.get("/products")
        return responses.map { $0.toDomain() }
    }
    
    func getProductById(_ productId: UUID) async throws -> Product {
        let response: ProductResponse = try await apiClient.get("/products/\(productId.uuidString)")
        return response.toDomain()
    }
    
    func getUserFavorites(userId: UUID) async throws -> [Favorite]? {
        let responses: [FavoriteResponse]? = try await apiClient.get("/users/\(userId.uuidString)/favourites")
        return responses?.map { $0.toDomain() }
    }
    
    func isFavorite(userId: UUID, productId: UUID) async throws -> Bool {
        let response: Bool = try await apiClient.get("/products/\(productId.uuidString)/is_favourite/\(userId.uuidString)")
        return response
    }
    
    func addToFavorites(userId: UUID, productId: UUID) async throws {
        let request = FavoriteRequest(productId: productId)
        let _: EmptyResponse = try await apiClient.post("/users/\(userId.uuidString)/favourites", body: request)
    }
    
    func removeFromFavorites(userId: UUID, productId: UUID) async throws {
        let _: EmptyResponse = try await apiClient.delete("/users/\(userId.uuidString)/favourites/\(productId.uuidString)")
    }
    
    func getReviews(productId: UUID) async throws -> [Review] {
        let responses: [ReviewResponse] = try await apiClient.get("/products/\(productId.uuidString)/reviews")
        
        let currentUserName = UserDefaultsService.shared.name
        
        return responses.map { response in
            response.toDomain(userName: currentUserName)
        }
    }
    
    func addReview(userId: UUID, productId: UUID, mark: Int, review: String) async throws {
        let request = ReviewRequest(userId: userId, mark: mark, review: review)
        let _: EmptyResponse = try await apiClient.post("/products/\(productId.uuidString)/reviews", body: request)
    }
    
    func updateReview(userId: UUID, productId: UUID, reviewId: UUID, mark: Int, review: String) async throws {
        let request = ReviewRequest(userId: userId, mark: mark, review: review)
        let _: ReviewResponse = try await apiClient.putReturning("/products/\(productId.uuidString)/reviews/\(reviewId.uuidString)", body: request)
    }
    
    func deleteReview(productId: UUID, reviewId: UUID) async throws {
        let _: EmptyResponse = try await apiClient.delete("/products/\(productId.uuidString)/reviews/\(reviewId.uuidString)")
    }
}
