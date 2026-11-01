//
//  Ingredient.swift
//  RecipeBox
//
//  Created by nktmahov on 06.10.26.
//

import Foundation

struct Ingredient: Codable, Equatable, Identifiable, Sendable {
    let name: String
    let measure: String

    var id: String {
        name + measure
    }
}
