//
//  GetFavoritesUseCase.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 17.10.2026.
//

import Foundation

protocol GetFavoritesUseCaseProtocol {
    func execute() async throws -> [Quote]
}

final class GetFavoritesUseCase: GetFavoritesUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol
    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Quote] {
        try await repository.getAll()
    }
}
