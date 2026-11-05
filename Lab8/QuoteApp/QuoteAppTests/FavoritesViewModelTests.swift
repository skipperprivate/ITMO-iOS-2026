//
//  FavoritesViewModelTests.swift
//  QuoteAppTests
//
//  Created by Кирилл Матвеев on 29.10.2026.
//

import XCTest
@testable import QuoteApp

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    
    private var sut: FavoritesViewModel?
    private var mockGetFavorites: MockGetFavoritesUseCase?
    private var mockRemoveFavorite: MockRemoveFavoriteUseCase?
    
    override func setUp() {
        super.setUp()
        mockGetFavorites = MockGetFavoritesUseCase()
        mockRemoveFavorite = MockRemoveFavoriteUseCase()
        
        guard let mockGetFavorites, let mockRemoveFavorite else { return }
        
        sut = FavoritesViewModel(
            getFavoritesUseCase: mockGetFavorites,
            removeFavoriteUseCase: mockRemoveFavorite
        )
    }
    
    override func tearDown() {
        sut = nil
        mockGetFavorites = nil
        mockRemoveFavorite = nil
        super.tearDown()
    }
    
    func test_remove_updatesFavoritesList() async throws {
        let sut = try XCTUnwrap(sut)
        let mockGet = try XCTUnwrap(mockGetFavorites)
        
        let quote1 = Quote(id: 1, content: "First", author: "A")
        let quote2 = Quote(id: 2, content: "Second", author: "B")

        mockGet.result = .success([quote1, quote2])
        await sut.load()
        XCTAssertEqual(sut.favorites.count, 2, "Должно быть загружено 2 цитаты")
        
        mockGet.result = .success([quote2])
        
        await sut.remove(quote1)
        
        XCTAssertEqual(sut.favorites.count, 1, "В списке должна остаться 1 цитата")
        XCTAssertEqual(sut.favorites.first?.id, 2, "Должна остаться вторая цитата")
        XCTAssertNil(sut.errorMessage)
    }
}
