//
//  FavoritesViewModel.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [Quote] = []
    @Published var errorMessage: String?
    
    private let getFavoritesUseCase: GetFavoritesUseCaseProtocol
    private let removeFavoriteUseCase: RemoveFavoriteUseCaseProtocol
    
    init(getFavoritesUseCase: GetFavoritesUseCaseProtocol,
         removeFavoriteUseCase: RemoveFavoriteUseCaseProtocol) {
        self.getFavoritesUseCase = getFavoritesUseCase
        self.removeFavoriteUseCase = removeFavoriteUseCase
    }
    
    func load() async {
        errorMessage = nil
        do {
            favorites = try await getFavoritesUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func remove(_ quote: Quote) async {
        errorMessage = nil
        do {
            try await removeFavoriteUseCase.execute(quote: quote)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
