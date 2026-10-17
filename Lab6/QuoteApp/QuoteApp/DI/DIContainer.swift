//
//  DIContainer.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import Foundation

@MainActor
final class DIContainer {
    static let shared = DIContainer()
    private init() {}
    
    private lazy var network: NetworkClientProtocol = NetworkClient()
    private lazy var coreDataStack: CoreDataStackProtocol = CoreDataStack()
    
    lazy var themeStore: ThemeStore = ThemeStore()
    
    private lazy var quoteRepository: QuoteRepositoryProtocol = QuoteRepository(network: network)
    private lazy var favoritesRepository: FavoritesRepositoryProtocol = CoreDataFavoritesRepository(stack: coreDataStack)
        
    private lazy var fetchQuoteUseCase = FetchQuoteOfTheDayUseCase(repository: quoteRepository)
    private lazy var getFavoritesUseCase = GetFavoritesUseCase(repository: favoritesRepository)
    private lazy var toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: favoritesRepository)
    
    func makeQuoteOfTheDayViewModel() -> QuoteOfTheDayViewModel {
        QuoteOfTheDayViewModel(
            fetchUseCase: fetchQuoteUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase
        )
    }
    
    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(repository: quoteRepository)
    }
    
    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel()
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel()
    }
}
