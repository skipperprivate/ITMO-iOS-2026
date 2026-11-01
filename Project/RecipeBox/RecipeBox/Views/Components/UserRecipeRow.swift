//
//  UserRecipeRow.swift
//  RecipeBox
//
//  Created by nktmahov on 11.10.26.
//

import SwiftUI
import UIKit

struct UserRecipeRow: View {
    let title: String
    let description: String
    let imageData: Data?

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "fork.knife")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 104, height: 84)
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 8)
        }
    }
}
