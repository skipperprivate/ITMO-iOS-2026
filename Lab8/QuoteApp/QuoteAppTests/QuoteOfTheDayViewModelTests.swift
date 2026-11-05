//
//  QuoteOfTheDayViewModelTests.swift
//  QuoteAppTests
//
//  Created by Кирилл Матвеев on 22.10.2026.
//

import XCTest
@testable import QuoteApp

@MainActor
final class QuoteOfTheDayViewModelTests: XCTestCase {
    
    private var sut: QuoteOfTheDayViewModel?
    private var mockFetch: MockFetchQuoteOfTheDayUseCase?
    private var mockCheck: MockCheckIsFavoriteUseCase?
    private var mockToggle: MockToggleFavoriteUseCase?
    
    override func setUp() {
        super.setUp()
        
        mockFetch = MockFetchQuoteOfTheDayUseCase()
        mockCheck = MockCheckIsFavoriteUseCase()
        mockToggle = MockToggleFavoriteUseCase()
        
        guard let mockFetch, let mockCheck, let mockToggle else { return }
                
        sut = QuoteOfTheDayViewModel(
            fetchUseCase: mockFetch,
            toggleFavoriteUseCase: mockToggle,
            checkFavoriteUseCase: mockCheck
        )
    }
    
    override func tearDown() {
        sut = nil
        mockFetch = nil
        mockCheck = nil
        mockToggle = nil
        super.tearDown()
    }
    
    func test_load_success_updatesProperties() async throws {
        let sut = try XCTUnwrap(sut)
        let mockFetch = try XCTUnwrap(mockFetch)
        let mockCheck = try XCTUnwrap(mockCheck)
        
        let sampleQuote = Quote(id: 1, content: "Test Content", author: "Test Author")
        mockFetch.result = .success(sampleQuote)
        mockCheck.result = true
        
        await sut.load()
        
        XCTAssertEqual(sut.quote, sampleQuote, "Цитата должна обновиться")
        XCTAssertTrue(sut.isFavorite, "Статус избранного должен быть true")
        XCTAssertFalse(sut.isLoading, "Загрузка должна завершиться")
        XCTAssertNil(sut.errorMessage, "Ошибки быть не должно")
    }
    
    func test_shareText_returnsFormattedString() async throws {
        let sut = try XCTUnwrap(sut)
        let mockFetch = try XCTUnwrap(mockFetch)
        
        let sampleQuote = Quote(id: 1, content: "Stay hungry", author: "Steve Jobs")
        mockFetch.result = .success(sampleQuote)
        
        await sut.load()
        let shareText = sut.shareText
        
        let expectedText = "\"Stay hungry\"\n- Steve Jobs"
        XCTAssertEqual(shareText, expectedText, "Текст сформирован неверно")
    }
}
