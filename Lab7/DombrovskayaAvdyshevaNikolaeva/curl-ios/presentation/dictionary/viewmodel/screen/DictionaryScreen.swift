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
                .font(.titleSerif)
                .foregroundStyle(Color(hex: "4A5B48"))
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "4A5B48").opacity(0.5))
                
                TextField("Поиск", text: $viewModel.searchQuery)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "4A5B48"))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
           
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.words) { word in
                        WordItem(word: word)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 8)
            }
        }
        .background(Color(hex: "F8F4ED").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.searchQuery) { _, _ in
            viewModel.filterWords()
        }
    }
}

private struct WordItem: View {
    let word: Word
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(word.name)
                .font(.system(size: 18, weight: .bold)) 
                .foregroundStyle(Color(hex: "4A5B48"))
            
            Text(word.description)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color(hex: "4A5B48").opacity(0.8))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
