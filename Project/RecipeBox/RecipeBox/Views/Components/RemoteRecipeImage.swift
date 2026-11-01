//
//  RemoteRecipeImage.swift
//  RecipeBox
//
//  Created by nktmahov on 11.10.26.
//

import SwiftUI

struct RemoteRecipeImage: View {
    let imageURL: URL?
    let height: CGFloat

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty:
                ProgressView()
            case .failure:
                Image(systemName: "fork.knife")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(.quaternary)
        .clipped()
    }
}
