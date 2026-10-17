//
//  FetchQuoteOfTheDayUseCase.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import Foundation

protocol FetchQuoteOfTheDayUseCaseProtocol {
    func execute() async throws -> Quote
}

final class FetchQuoteOfTheDayUseCase: FetchQuoteOfTheDayUseCaseProtocol {
    private let repository: QuoteRepositoryProtocol
    
    init(repository: QuoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> Quote {
        try await repository.fetchRandomQuote()
    }
}
