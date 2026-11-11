import Foundation

final class GetProductsUseCase {
    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Product] {
        try await repository.getProducts()
    }
}
