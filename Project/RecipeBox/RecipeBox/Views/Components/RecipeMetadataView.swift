//
//  RecipeMetadataView.swift
//  RecipeBox
//
//  Created by nktmahov on 10.10.26.
//

import SwiftUI

struct RecipeMetadataView: View {
    let title: String
    let category: String?
    let area: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.largeTitle.bold())

            HStack {
                if let category {
                    Label(category, systemImage: "tag")
                }
                if let area {
                    Label(area, systemImage: "globe")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
}
