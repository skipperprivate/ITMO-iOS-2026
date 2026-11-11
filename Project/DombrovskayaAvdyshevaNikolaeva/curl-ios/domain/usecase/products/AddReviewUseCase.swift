import Foundation

final class AddReviewUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute(userId: UUID, productId: UUID, mark: Int, reviewText: String) async throws {
        try await repository.addReview(
            userId: userId,
            productId: productId,
            mark: mark,
            review: reviewText
        )
    }
}
