import XCTest
@testable import QuotesOfTheDay

final class MockQuoteService: QuoteServiceProtocol {

    var response: QuotesResponse?
    var shouldThrowError = false

    func fetchQuotes(limit: Int, skip: Int) async throws -> QuotesResponse {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }

        guard let response else {
            throw URLError(.badServerResponse)
        }

        return response
    }

    func fetchRandomQuote() async throws -> Quote {
        throw URLError(.badServerResponse)
    }

    func fetchQuote(id: Int) async throws -> Quote {
        throw URLError(.badServerResponse)
    }
}


final class QuotesViewModelTests: XCTestCase {

    @MainActor
    func testLoadQuotesSuccess() async {

        let mockService = MockQuoteService()

        mockService.response = QuotesResponse(
            quotes: [
                Quote(
                    id: 1,
                    quote: "Test quote",
                    author: "Test author"
                ),
                Quote(
                    id: 2,
                    quote: "Second quote",
                    author: "Second author"
                )
            ],
            total: 2,
            skip: 0,
            limit: 10
        )

        let viewModel = QuotesViewModel(
            service: mockService
        )

        await viewModel.loadQuotes()

        XCTAssertEqual(viewModel.quotes.count, 2)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }


    @MainActor
    func testLoadQuotesError() async {

        let mockService = MockQuoteService()
        mockService.shouldThrowError = true

        let viewModel = QuotesViewModel(
            service: mockService
        )

        await viewModel.loadQuotes()

        XCTAssertTrue(viewModel.quotes.isEmpty)

        XCTAssertEqual(
            viewModel.errorMessage,
            "Не удалось загрузить цитаты"
        )

        XCTAssertFalse(viewModel.isLoading)
    }
}
