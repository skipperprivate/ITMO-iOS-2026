//
//  FavoritesViewModel.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [Quote] = [Quote(id: 123, content: "Test", author: "test author")]
    
    
}
