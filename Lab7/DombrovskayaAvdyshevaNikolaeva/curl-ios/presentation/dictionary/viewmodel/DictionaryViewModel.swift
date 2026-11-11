//
//  DictionaryViewModel.swift
//  curl-ios
//
//  Created by Nadineenik on 12.10.2026.
//

import SwiftUI

@MainActor
final class DictionaryViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published private(set) var words: [Word] = []
    
    private let allWords: [Word]
    
    init(allWords: [Word] = DictionaryData.words) {
        self.allWords = allWords
        self.words = allWords
    }
    
    
    func filterWords() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if query.isEmpty {
            words = allWords
        } else {
            words = allWords.filter {
                $0.name.localizedCaseInsensitiveContains(query)
            }
        }
    }
}
