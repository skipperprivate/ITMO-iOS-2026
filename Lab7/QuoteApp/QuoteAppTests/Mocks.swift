//
//  Mocks.swift
//  QuoteAppTests
//
//  Created by Кирилл Матвеев on 22.10.2026.
//

import Foundation
@testable import QuoteApp

final class MockFetchQuoteOfTheDayUseCase: FetchQuoteOfTheDayUseCaseProtocol {
    var result: Result<Quote, Error> = .failure(APIError.noData)
    func execute() async throws -> Quote { try result.get() }
}

final class MockCheckIsFavoriteUseCase: CheckIsFavoriteUseCaseProtocol {
    var result: Bool = false
    func execute(quote: Quote) async throws -> Bool { result }
}

final class MockToggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol {
    var result: Bool = false
    func execute(quote: Quote) async throws -> Bool { result }
}
