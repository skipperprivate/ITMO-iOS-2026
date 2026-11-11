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

    @Published private(set) var userId: UUID?

    private let getProductsUseCase: GetProductsUseCase
    private let getUserFavoritesUseCase: GetUserFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let getReviewsUseCase: GetReviewsUseCase
    private let addReviewUseCase: AddReviewUseCase
    private let updateReviewUseCase: UpdateReviewUseCase
    private let deleteReviewUseCase: DeleteReviewUseCase

    init(
        getProductsUseCase: GetProductsUseCase,
        getUserFavoritesUseCase: GetUserFavoritesUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        getReviewsUseCase: GetReviewsUseCase,
        addReviewUseCase: AddReviewUseCase,
        updateReviewUseCase: UpdateReviewUseCase,
        deleteReviewUseCase: DeleteReviewUseCase
    ) {
        self.getProductsUseCase = getProductsUseCase
        self.getUserFavoritesUseCase = getUserFavoritesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.getReviewsUseCase = getReviewsUseCase
        self.addReviewUseCase = addReviewUseCase
        self.updateReviewUseCase = updateReviewUseCase
        self.deleteReviewUseCase = deleteReviewUseCase

        loadUserId()
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

    private func loadUserId() {
        Task {
            do {
                guard
                    let raw = AuthManager.shared.getUserId(),
                    let uuid = UUID(uuidString: raw)
                else {
                    self.error = "Пользователь не авторизован"
                    return
                }
                self.userId = uuid
                await loadProducts()
                await loadFavorites(userId: uuid)
            }
        }
    }

    private func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await getProductsUseCase.execute()
            error = nil
        } catch {
            self.error = "Ошибка загрузки товаров: \(error.localizedDescription)"
        }
    }

    private func loadFavorites(userId: UUID) async {
        do {
            favorites = try await getUserFavoritesUseCase.execute(userId: userId)
        } catch {
            self.error = "Ошибка загрузки избранного: \(error.localizedDescription)"
        }
    }

    func loadReviews(_ productId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await getReviewsUseCase.execute(productId: productId)
            reviews = fetched.sorted { $0.createdAt > $1.createdAt }
            error = nil
        } catch {
            self.error = "Ошибка загрузки отзывов: \(error.localizedDescription)"
        }
    }

    func toggleFavorite(productId: UUID) async {
        guard let userId else {
            error = "Пользователь не авторизован"
            return
        }

        do {
            try await toggleFavoriteUseCase.execute(userId: userId, productId: productId)

            if favorites.contains(where: { $0.productId == productId }) {
                favorites = favorites.filter { $0.productId != productId }
            } else {
                favorites.append(Favorite(userId: userId, productId: productId, product: nil))
            }
            error = nil
        } catch {
            self.error = "Не удалось обновить избранное: \(error.localizedDescription)"
        }
    }

    func submitReview(productId: UUID, mark: Int, reviewText: String) async {
        guard let userId else {
            error = "Пользователь не авторизован"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await addReviewUseCase.execute(
                userId: userId,
                productId: productId,
                mark: mark,
                reviewText: reviewText
            )
            await loadReviews(productId)
            error = nil
        } catch {
            print("submitReview error:", error)
            if let apiError = error as? ApiError {
                switch apiError {
                case .http(let code, let message):
                    print("HTTP \(code), body: \(message ?? "nil")")
                case .network(let networkError):
                    print("NETWORK:", networkError)
                case .decoding(let decodingError):
                    print("DECODING:", decodingError)
                case .invalidURL:
                    print("INVALID URL")
                case .unknown:
                    print("UNKNOWN")
                }
            }
            self.error = "Ошибка при отправке отзыва: \((error as? ApiError)?.code ?? -1)"
        }
    }

    func updateReview(productId: UUID, reviewId: UUID, mark: Int, reviewText: String) async {
        guard let userId else {
            error = "Пользователь не авторизован"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await updateReviewUseCase.execute(
                userId: userId,
                productId: productId,
                reviewId: reviewId,
                mark: mark,
                reviewText: reviewText
            )
            await loadReviews(productId)
            error = nil
        } catch {
            if let apiError = error as? ApiError {
                switch apiError.code {
                case 403:
                    self.error = "Нельзя редактировать отзыв спустя 24 часа после создания"
                case 404:
                    self.error = "Отзыв не найден"
                case 400:
                    self.error = "Некорректные данные отзыва"
                default:
                    self.error = "Ошибка при обновлении отзыва: \(apiError.code)"
                }
            } else {
                self.error = "Ошибка при обновлении отзыва: \(error.localizedDescription)"
            }
        }
    }

    func deleteReview(productId: UUID, reviewId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await deleteReviewUseCase.execute(productId: productId, reviewId: reviewId)
            reviews = reviews.filter { $0.id != reviewId }
            error = nil
        } catch {
            self.error = "Ошибка при удалении отзыва: \(error.localizedDescription)"
        }
    }

    func getCurrentUserId() -> UUID? {
        userId
    }

    func getCurrentUsername() -> String? {
        AuthManager.shared.getUsername() ?? "user"
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

    func refreshData() {
        if let userId {
            Task {
                await loadProducts()
                await loadFavorites(userId: userId)
            }
        } else {
            loadUserId()
        }
    }
}

enum ProductsTab {
    case allProducts
    case favoriteProducts
}
