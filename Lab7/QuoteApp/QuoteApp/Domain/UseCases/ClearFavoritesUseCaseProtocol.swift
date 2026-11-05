//
//  ClearFavoritesUseCaseProtocol.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 22.10.2026.
//

import Foundation

protocol ClearFavoritesUseCaseProtocol {
    func execute() async throws
}

final class ClearFavoritesUseCase: ClearFavoritesUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol
    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws {
        try await repository.clear()
    }
}
