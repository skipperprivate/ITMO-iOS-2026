import Foundation

final class GetReviewsUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(productId: UUID) async throws -> [Review] {
        try await repository.fetchReviews(productId: productId)
    }
}
