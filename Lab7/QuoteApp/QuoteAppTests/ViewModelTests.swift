//
//  ViewModelTests.swift
//  QuoteAppTests
//
//  Created by Кирилл Матвеев on 22.10.2026.
//

import XCTest
@testable import QuoteApp

@MainActor
final class ViewModelTests: XCTestCase {
    
    private var sut: QuoteOfTheDayViewModel!
    private var mockFetch: MockFetchQuoteOfTheDayUseCase!
    private var mockCheck: MockCheckIsFavoriteUseCase!
    private var mockToggle: MockToggleFavoriteUseCase!
    private var sampleQuote: Quote!
    
    override func setUp() {
        super.setUp()
        
        mockFetch = MockFetchQuoteOfTheDayUseCase()
        mockCheck = MockCheckIsFavoriteUseCase()
        mockToggle = MockToggleFavoriteUseCase()
        
        sut = QuoteOfTheDayViewModel(fetchUseCase: mockFetch, toggleFavoriteUseCase: mockToggle, checkIsFavoriteUseCase: mockCheck)
        
        sampleQuote = Quote(id: 1, content: "Test quote", author: "Test")
    }
    
    override func tearDown() {
        sut = nil
        mockFetch = nil
        mockCheck = nil
        mockToggle = nil
        sampleQuote = nil
        super.tearDown()
    }
    
    func test_load_success() async {
        mockFetch.result = .success(sampleQuote)
        
        await sut.load()
        
        XCTAssertEqual(sut.quote, sampleQuote)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_shareText() async {
        mockFetch.result = .success(sampleQuote)
        
        await sut.load()
        let shareText = sut.shareText
        
        let expectedText = "\"Test quote\"\n- Test"
        XCTAssertEqual(shareText, expectedText)
    }
}
