import Foundation

@MainActor
enum ProductsViewModelFactory {
    static func make() -> ProductsViewModel {
        let repository: ProductRepository = ProductRepositoryImpl()

        return ProductsViewModel(
            getProductsUseCase: GetProductsUseCase(repository: repository),
            getUserFavoritesUseCase: GetUserFavoritesUseCase(repository: repository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: repository),
            getReviewsUseCase: GetReviewsUseCase(repository: repository),
            addReviewUseCase: AddReviewUseCase(repository: repository),
            updateReviewUseCase: UpdateReviewUseCase(repository: repository),
            deleteReviewUseCase: DeleteReviewUseCase(repository: repository)
        )
    }
}
