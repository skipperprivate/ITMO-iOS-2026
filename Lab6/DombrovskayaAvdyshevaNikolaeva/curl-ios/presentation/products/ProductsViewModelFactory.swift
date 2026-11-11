import Foundation

@MainActor
enum ProductsViewModelFactory {
    static func make() -> ProductsViewModel {
        let repository: ProductRepository = ProductRepositoryImpl()

        return ProductsViewModel(
            getProductsUseCase: GetProductsUseCase(repository: repository),
            getReviewsUseCase: GetReviewsUseCase(repository: repository)
        )
    }
}
