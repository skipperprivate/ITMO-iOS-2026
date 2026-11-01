//
//  IngredientListView.swift
//  RecipeBox
//
//  Created by nktmahov on 09.10.26.
//

import SwiftUI

struct IngredientListView: View {
    let ingredients: [Ingredient]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ингредиенты")
                .font(.title2.bold())

            ForEach(ingredients) { ingredient in
                HStack(alignment: .firstTextBaseline) {
                    Text(ingredient.name)
                    Spacer()
                    Text(ingredient.measure)
                        .foregroundStyle(.secondary)
                }
                Divider()
            }
        }
        .padding(.horizontal)
    }
}
