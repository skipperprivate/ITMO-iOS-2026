//
//  CheckIsFavoriteUseCase.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 22.10.2026.
//

import Foundation

protocol CheckIsFavoriteUseCaseProtocol {
    func execute(quote: Quote) async throws -> Bool
}

final class CheckIsFavoriteUseCase: CheckIsFavoriteUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol
    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(quote: Quote) async throws -> Bool {
        try await repository.isFavorite(quote)
    }
}
