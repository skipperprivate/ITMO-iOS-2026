//
//  DictionaryScreen.swift
//  curl-ios
//
//  Created by Nadineenik on 12.10.2026.
//

import SwiftUI

struct DictionaryScreen: View {
    @StateObject private var viewModel = DictionaryViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Словарь")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.darkGreen)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            
            TextField("Поиск", text: $viewModel.searchQuery)
                .padding(12)
                .background(Color.lightBeige)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.words) { word in
                        WordItem(word: word)
                            .padding(.horizontal, 24)
                    }
                }
            }
        }
        .background(Color.white)
        .navigationTitle("Словарь")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.searchQuery) { _, _ in
            viewModel.filterWords()
        }
    }
}

private struct WordItem: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(word.name)
                .font(.title3.bold())
                .foregroundStyle(Color.darkGreen)
            
            Text(word.description)
                .font(.body)
                .foregroundStyle(Color.darkGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.lightBeige)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.vertical, 8)
    }
}
