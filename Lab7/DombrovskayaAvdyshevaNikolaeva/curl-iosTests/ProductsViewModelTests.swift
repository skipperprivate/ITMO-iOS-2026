import XCTest
@testable import curl_ios

@MainActor
final class ProductsViewModelTests: XCTestCase {

    private var repository: MockProductRepository!

    override func setUp() {
        super.setUp()
        repository = MockProductRepository()
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    private func makeSUT() -> ProductsViewModel {
        ProductsViewModel(
            getProductsUseCase: GetProductsUseCase(repository: repository!),
            getReviewsUseCase: GetReviewsUseCase(repository: repository!)
        )
    }


    func testInitLoadsProductsFromRepository() async {
        let expected = [
            makeProduct(name: "Шампунь", tags: ["Низкая пористость"]),
            makeProduct(name: "Кондиционер", tags: ["Высокая пористость"])
        ]
        repository.productsResult = .success(expected)

        let sut = makeSUT()
        await waitForLoad(sut)

        XCTAssertEqual(sut.products.map(\.name), ["Шампунь", "Кондиционер"])
        XCTAssertEqual(repository.fetchProductsCallCount, 1,
                       "fetchProducts должен вызываться ровно один раз при инициализации")
        XCTAssertFalse(sut.isLoading, "После загрузки isLoading должен стать false")
        XCTAssertNil(sut.error, "При успешной загрузке error должен быть nil")
    }


    func testFilteredProductsRespectsSelectedTags() async {
        let productA = makeProduct(name: "A", tags: ["Низкая пористость", "Натуральные"])
        let productB = makeProduct(name: "B", tags: ["Высокая пористость", "Окрашенные"])
        let productC = makeProduct(name: "C", tags: ["Низкая пористость", "Окрашенные"])
        repository.productsResult = .success([productA, productB, productC])

        let sut = makeSUT()
        await waitForLoad(sut)

        XCTAssertEqual(sut.filteredProducts.count, 3)

        sut.toggleTag(category: "Пористость", tag: "Низкая пористость")
        XCTAssertEqual(sut.filteredProducts.map(\.name), ["A", "C"])

        sut.toggleTag(category: "Окрашенность", tag: "Окрашенные")
        XCTAssertEqual(sut.filteredProducts.map(\.name), ["C"],
                       "Теги должны комбинироваться: только C подходит по обоим")

        sut.toggleTag(category: "Окрашенность", tag: "Окрашенные")
        XCTAssertEqual(sut.filteredProducts.map(\.name), ["A", "C"],
                       "Повторный тап по тегу должен его снимать")

        sut.clearAllFilters()
        XCTAssertEqual(sut.filteredProducts.count, 3)
        XCTAssertNil(sut.porosityTag)
        XCTAssertNil(sut.coloringTag)
        XCTAssertNil(sut.thicknessTag)
    }


    func testToggleFavoriteAddsAndRemovesProduct() async {
        let product = makeProduct(name: "Масло", tags: [])
        repository.productsResult = .success([product])

        let sut = makeSUT()
        await waitForLoad(sut)

        XCTAssertTrue(sut.favorites.isEmpty)
        XCTAssertTrue(sut.favoriteProducts.isEmpty)

        await sut.toggleFavorite(productId: product.id)

        XCTAssertEqual(sut.favorites.count, 1)
        XCTAssertEqual(sut.favorites.first?.productId, product.id)
        XCTAssertEqual(sut.favoriteProducts.map(\.name), ["Масло"])

        await sut.toggleFavorite(productId: product.id)

        XCTAssertTrue(sut.favorites.isEmpty)
        XCTAssertTrue(sut.favoriteProducts.isEmpty)
    }
    
    @MainActor
    private func waitForLoad(_ vm: ProductsViewModel, timeout: TimeInterval = 2.0) async {
        let deadline = Date().addingTimeInterval(timeout)
        while vm.isLoading && Date() < deadline {
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
        try? await Task.sleep(nanoseconds: 50_000_000)
    }

    private func makeProduct(
        name: String,
        tags: [String],
        imageUrlString: String? = nil
    ) -> Product {
        Product(
            id: UUID(),
            name: name,
            description: "\(name) описание",
            tags: tags,
            imageUrlString: imageUrlString
        )
    }
}
