//
//  SettingsViewModel.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    private let defaults: UserDefaults
    private let clearFavoritesUseCase: ClearFavoritesUseCaseProtocol
    
    private enum Keys {
        static let theme = "settings.theme"
    }
    
    @Published var clearResultMessage: String?
    
    init(defaults: UserDefaults = .standard,
         clearFavoritesUseCase: ClearFavoritesUseCaseProtocol) {
        self.defaults = defaults
        self.clearFavoritesUseCase = clearFavoritesUseCase
    }
    
    func clearFavorites() async {
        do {
            try await clearFavoritesUseCase.execute()
            clearResultMessage = "Избранное очищено"
        } catch { clearResultMessage = "Ошибка очистки" }
    }
}
