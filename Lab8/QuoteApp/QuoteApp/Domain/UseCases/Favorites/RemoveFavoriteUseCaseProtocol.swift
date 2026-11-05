//
//  RemoveFavoriteUseCaseProtocol.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 22.10.2026.
//

import Foundation

protocol RemoveFavoriteUseCaseProtocol {
    func execute(quote: Quote) async throws
}

final class RemoveFavoriteUseCase: RemoveFavoriteUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol
    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(quote: Quote) async throws {
        try await repository.remove(quote)
    }
}
