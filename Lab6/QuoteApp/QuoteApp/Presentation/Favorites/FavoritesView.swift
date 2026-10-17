//
//  FavoritesView.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favorites.isEmpty {
                    
                } else {
                    List {
                        ForEach(viewModel.favorites) { quote in
                            
                        }
                    }
                }
            }
            .navigationTitle("Избранное")
            .onAppear {  }
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: FavoritesViewModel())
    }
}
