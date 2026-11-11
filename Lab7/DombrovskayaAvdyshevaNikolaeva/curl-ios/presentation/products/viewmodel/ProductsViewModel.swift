import Foundation
import Combine

@MainActor
final class ProductsViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var favorites: [Favorite] = []
    @Published private(set) var reviews: [Review] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?
    @Published private(set) var selectedTab: ProductsTab = .allProducts

    @Published private(set) var porosityTag: String?
    @Published private(set) var coloringTag: String?
    @Published private(set) var thicknessTag: String?

    private let getProductsUseCase: GetProductsUseCase
    private let getReviewsUseCase: GetReviewsUseCase

    private let currentUserId: UUID = UUID()
    private let currentUsername: String = "user"

    init(
        getProductsUseCase: GetProductsUseCase,
        getReviewsUseCase: GetReviewsUseCase
    ) {
        self.getProductsUseCase = getProductsUseCase
        self.getReviewsUseCase = getReviewsUseCase

        Task { await loadProducts() }
    }

    var filteredProducts: [Product] {
        products.filter { product in
            let tags = Set(product.tags)
            let porosityMatch = porosityTag == nil || tags.contains(porosityTag!)
            let coloringMatch = coloringTag == nil || tags.contains(coloringTag!)
            let thicknessMatch = thicknessTag == nil || tags.contains(thicknessTag!)
            return porosityMatch && coloringMatch && thicknessMatch
        }
    }

    var favoriteProducts: [Product] {
        products.filter { product in
            favorites.contains { $0.productId == product.id }
        }
    }

    private func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await getProductsUseCase.execute()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadReviews(_ productId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        do {
            reviews = try await getReviewsUseCase.execute(productId: productId)
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func toggleFavorite(productId: UUID) async {
        let isCurrentlyFavorite = favorites.contains { $0.productId == productId }
        if isCurrentlyFavorite {
            favorites = favorites.filter { $0.productId != productId }
        } else {
            let product = products.first { $0.id == productId }
            favorites.append(
                Favorite(
                    userId: currentUserId,
                    productId: productId,
                    product: product
                )
            )
        }
    }

    func getCurrentUserId() -> UUID? {
        currentUserId
    }

    func getCurrentUsername() -> String? {
        currentUsername
    }

    func submitReview(productId: UUID, mark: Int, reviewText: String) async {
        let newReview = Review(
            id: UUID(),
            productId: productId,
            userId: currentUserId,
            userName: currentUsername,
            rating: mark,
            comment: reviewText,
            createdAt: Date()
        )
        reviews.insert(newReview, at: 0)
    }

    func updateReview(productId: UUID, reviewId: UUID, mark: Int, reviewText: String) async {
        guard let index = reviews.firstIndex(where: { $0.id == reviewId }) else { return }
        let old = reviews[index]

        let updated = Review(
            id: old.id,
            productId: old.productId,
            userId: old.userId,
            userName: old.userName,
            rating: mark,
            comment: reviewText,
            createdAt: old.createdAt
        )
        reviews[index] = updated
    }

    func deleteReview(_ productId: UUID, _ reviewId: UUID) async {
        reviews.removeAll { $0.id == reviewId }
    }

    func toggleTag(category: String, tag: String) {
        switch category {
        case "Пористость":
            porosityTag = porosityTag == tag ? nil : tag
        case "Окрашенность":
            coloringTag = coloringTag == tag ? nil : tag
        case "Толщина":
            thicknessTag = thicknessTag == tag ? nil : tag
        default:
            break
        }
    }

    func selectTab(_ tab: ProductsTab) {
        selectedTab = tab
    }

    func clearAllFilters() {
        porosityTag = nil
        coloringTag = nil
        thicknessTag = nil
    }

    func clearError() {
        error = nil
    }
}

enum ProductsTab {
    case allProducts
    case favoriteProducts
}
