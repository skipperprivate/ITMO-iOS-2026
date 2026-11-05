//
//  ToggleFavoriteUseCase.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 17.10.2026.
//

import Foundation

protocol ToggleFavoriteUseCaseProtocol {
    func execute(quote: Quote) async throws -> Bool
}

final class ToggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol
    init(repository: FavoritesRepositoryProtocol) { self.repository = repository }
    
    func execute(quote: Quote) async throws -> Bool {
        if try await repository.isFavorite(quote) {
            try await repository.remove(quote)
            return false
        } else {
            try await repository.add(quote)
            return true
        }
    }
}
