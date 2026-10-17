//
//  HistoryViewModel.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var quotes: [Quote] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: QuoteRepositoryProtocol
    
    private let pageSize = 20
    private var currentOffset = 0
    private var canLoadMore = true
    private var favoriteIds: Set<Int> = []
    
    init(repository: QuoteRepositoryProtocol) {
        self.repository = repository
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
    
    
    private func loadPage() async {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let page = try await repository.fetchQuotes(offset: currentOffset, limit: pageSize)
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
