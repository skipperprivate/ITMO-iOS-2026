//
//  QuoteListViewModel.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import Foundation
import Combine

@MainActor
final class QuoteListViewModel: ObservableObject {
    @Published private(set) var quotes: [Quote] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private let fetchQuotesUseCase: FetchQuotesUseCaseProtocol
    private let getFavoritesUseCase: GetFavoritesUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    
    private let pageSize = 20
    private var currentOffset = 0
    private var canLoadMore = true
    private var favoriteIds: Set<Int> = []
    
    init(fetchQuotesUseCase: FetchQuotesUseCaseProtocol,
         getFavoritesUseCase: GetFavoritesUseCaseProtocol,
         toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol) {
            self.fetchQuotesUseCase = fetchQuotesUseCase
            self.getFavoritesUseCase = getFavoritesUseCase
            self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }
    
    func loadInitial() async {
        currentOffset = 0
        canLoadMore = true
        quotes = []
        await loadPage()
    }
    
    func loadMoreIfNeedeed(currentItem: Quote) async {
        guard let index = quotes.firstIndex(where: { $0.id == currentItem.id }) else { return }
        if index >= quotes.count - 3 {
            await loadPage()
        }
    }
    
    func isFavorite(_ quote: Quote) -> Bool { favoriteIds.contains(quote.id) }
    
    func toggleFavorite(quote: Quote) async {
        do {
            let isNowFavorite = try await toggleFavoriteUseCase.execute(quote: quote)
            if isNowFavorite {
                favoriteIds.insert(quote.id)
            } else {
                favoriteIds.remove(quote.id)
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func refreshFavorites() async {
        if let favorites = try? await getFavoritesUseCase.execute() {
            favoriteIds = Set(favorites.map(\.id))
        }
    }
    
    private func loadPage() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let page = try await fetchQuotesUseCase.execute(offset: currentOffset, limit: pageSize)
            if page.isEmpty {
                canLoadMore = false
            } else {
                quotes.append(contentsOf: page)
                currentOffset += pageSize
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
