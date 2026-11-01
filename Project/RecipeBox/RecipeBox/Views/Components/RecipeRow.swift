//
//  RecipeRow.swift
//  RecipeBox
//
//  Created by nktmahov on 11.10.26.
//

import SwiftUI

struct RecipeRow: View {
    let title: String
    let imageURL: URL?
    let subtitle: String?

    var body: some View {
        HStack(spacing: 12) {
            RemoteRecipeImage(imageURL: imageURL, height: 84)
                .frame(width: 104)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 8)
        }
    }
}
