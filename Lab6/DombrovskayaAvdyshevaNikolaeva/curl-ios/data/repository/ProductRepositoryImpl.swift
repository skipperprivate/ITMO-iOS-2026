import Foundation

final class ProductRepositoryImpl: ProductRepository {
    private let apiClient: ApiService

    init(apiClient: ApiService = .shared) {
        self.apiClient = apiClient
    }

    func fetchProducts() async throws -> [Product] {
        let response: ProductsResponseDTO = try await apiClient.get(
            "/products",
            queryItems: [
                URLQueryItem(name: "limit", value: "30"),
                URLQueryItem(name: "select", value: "id,title,description,category,price,rating,brand,thumbnail,tags")
            ]
        )

        return response.products.map { dto in
            Product(
                id: UUID(),
                name: dto.title,
                description: dto.description,
                tags: dto.tags ?? [dto.category],
                imageUrlString: dto.thumbnail
     
            )
        }
    }

    func fetchReviews(productId: UUID) async throws -> [Review] {
        return []
    }

    func toggleFavorite(userId: UUID, productId: UUID) async throws {
        // заглушка
    }
}
