//
//  FetchQuotesUseCaseProtocol.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 26.10.2026.
//

import Foundation

protocol FetchQuotesUseCaseProtocol {
    func execute(offset: Int, limit: Int) async throws -> [Quote]
}

final class FetchQuotesUseCase: FetchQuotesUseCaseProtocol {
    private let repository: QuoteRepositoryProtocol
    init(repository: QuoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(offset: Int, limit: Int) async throws -> [Quote] {
        try await repository.fetchQuotes(offset: offset, limit: limit)
    }
}
