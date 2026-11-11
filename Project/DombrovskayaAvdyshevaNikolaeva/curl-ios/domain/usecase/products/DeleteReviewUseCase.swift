import Foundation

final class DeleteReviewUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(productId: UUID, reviewId: UUID) async throws {
        try await repository.deleteReview(productId: productId, reviewId: reviewId)
    }
}
