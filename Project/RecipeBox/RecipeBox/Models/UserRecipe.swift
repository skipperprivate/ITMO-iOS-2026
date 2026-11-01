//
//  UserRecipe.swift
//  RecipeBox
//
//  Created by nktmahov on 06.10.26.
//

import Foundation
import SwiftData

@Model
final class UserRecipe {
    var id: UUID
    var title: String
    var recipeDescription: String
    @Attribute(.externalStorage) var imageData: Data?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        recipeDescription: String,
        imageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.recipeDescription = recipeDescription
        self.imageData = imageData
        createdAt = .now
        updatedAt = .now
    }
}
