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
    private let checkIsFavoriteUseCase: CheckIsFavoriteUseCaseProtocol
    
    init(fetchUseCase: FetchQuoteOfTheDayUseCaseProtocol,
         toggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol,
         checkIsFavoriteUseCase: CheckIsFavoriteUseCaseProtocol) {
        self.fetchUseCase = fetchUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.checkIsFavoriteUseCase = checkIsFavoriteUseCase
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let newQuote = try await fetchUseCase.execute()
            self.quote = newQuote
            self.isFavorite = (try? await checkIsFavoriteUseCase.execute(quote: newQuote)) ?? false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleFavorite() async {
        guard let quote else { return }
        do {
            isFavorite = try await toggleFavoriteUseCase.execute(quote: quote)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    var shareText: String {
        guard let quote else { return "" }
        return "\"\(quote.content)\"\n- \(quote.author)"
    }
}
