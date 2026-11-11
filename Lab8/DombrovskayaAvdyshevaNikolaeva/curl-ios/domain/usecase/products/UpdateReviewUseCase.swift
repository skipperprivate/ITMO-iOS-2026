import Foundation

final class UpdateReviewUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(userId: UUID, productId: UUID, reviewId: UUID, mark: Int, reviewText: String) async throws {
        try await repository.updateReview(
            userId: userId,
            productId: productId,
            reviewId: reviewId,
            mark: mark,
            review: reviewText
        )
    }
}
