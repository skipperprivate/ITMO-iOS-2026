//
//  QuoteOfTheDayViewModel.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import Foundation
import Combine

@MainActor
final class QuoteOfTheDayViewModel: ObservableObject {
    @Published private(set) var quote: Quote?
    @Published private(set) var isLoading = false
    @Published private(set) var isFavorite = false
    @Published var errorMessage: String?
    
    private let fetchUseCase: FetchQuoteOfTheDayUseCaseProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol
    
    init(fetchUseCase: FetchQuoteOfTheDayUseCaseProtocol,
         toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol) {
        self.fetchUseCase = fetchUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let newQuote = try await fetchUseCase.execute()
            self.quote = newQuote
            self.isFavorite = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    var shareText: String {
        guard let quote else { return "" }
        return "\"\(quote.content)\"\n- \(quote.author)"
    }
}
