//
//  UserRecipeDetailView.swift
//  RecipeBox
//
//  Created by nktmahov on 15.10.26.
//

import SwiftUI
import UIKit

struct UserRecipeDetailView: View {
    let recipe: UserRecipe
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageData = recipe.imageData,
                   let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipped()
                }

                Text(recipe.title)
                    .font(.largeTitle.bold())

                Text(recipe.recipeDescription)
                    .font(.body)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Изменить", systemImage: "pencil") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                RecipeEditorView(recipe: recipe)
            }
        }
    }
}
