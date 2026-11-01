//
//  APIRecipe.swift
//  RecipeBox
//
//  Created by nktmahov on 05.10.26.
//

import Foundation

struct APIRecipe: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let title: String
    let instructions: String
    let imageURL: URL?
    let category: String?
    let area: String?
    let ingredients: [Ingredient]

    var hasUsableImage: Bool {
        guard let imageURL,
              let scheme = imageURL.scheme?.lowercased() else {
            return false
        }
        return scheme == "https" || scheme == "http"
    }

    init(
        id: String,
        title: String,
        instructions: String,
        imageURL: URL?,
        category: String?,
        area: String?,
        ingredients: [Ingredient]
    ) {
        self.id = id
        self.title = title
        self.instructions = instructions
        self.imageURL = imageURL
        self.category = category
        self.area = area
        self.ingredients = ingredients
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RecipeCodingKey.self)
        id = try container.decode(String.self, forKey: RecipeCodingKey("idMeal"))
        title = try container.decode(String.self, forKey: RecipeCodingKey("strMeal"))
        instructions = try container.decodeIfPresent(String.self, forKey: RecipeCodingKey("strInstructions")) ?? ""
        category = try container.decodeIfPresent(String.self, forKey: RecipeCodingKey("strCategory"))
        area = try container.decodeIfPresent(String.self, forKey: RecipeCodingKey("strArea"))

        let imagePath = try container.decodeIfPresent(String.self, forKey: RecipeCodingKey("strMealThumb"))
        imageURL = imagePath.flatMap(URL.init(string:))

        ingredients = (1...20).compactMap { index in
            let name = try? container.decodeIfPresent(
                String.self,
                forKey: RecipeCodingKey("strIngredient\(index)")
            )
            let measure = try? container.decodeIfPresent(
                String.self,
                forKey: RecipeCodingKey("strMeasure\(index)")
            )
            guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty else {
                return nil
            }
            return Ingredient(
                name: name,
                measure: measure?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            )
        }
    }
}

private struct RecipeCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil

    init(_ stringValue: String) {
        self.stringValue = stringValue
    }

    init?(stringValue: String) {
        self.init(stringValue)
    }

    init?(intValue: Int) {
        return nil
    }
}
