//
//  RecipeBoxTests.swift
//  RecipeBoxTests
//
//  Created by Nikita Makhov on 15.10.2026.
//

import Foundation
import Testing
@testable import RecipeBox

struct RecipeBoxTests {
    @Test
    func decodesRecipeAndIngredients() throws {
        let json = Data("""
        {
          "idMeal": "52772",
          "strMeal": "Arrabiata",
          "strInstructions": "Cook the pasta.",
          "strMealThumb": "https://example.com/image.jpg",
          "strCategory": "Vegetarian",
          "strArea": "Italian",
          "strIngredient1": "Penne",
          "strMeasure1": "200 g",
          "strIngredient2": "",
          "strMeasure2": ""
        }
        """.utf8)

        let recipe = try JSONDecoder().decode(APIRecipe.self, from: json)

        #expect(recipe.id == "52772")
        #expect(recipe.title == "Arrabiata")
        #expect(recipe.ingredients == [Ingredient(name: "Penne", measure: "200 g")])
    }

    @Test
    func rejectsRecipeWithoutRemoteImage() {
        let recipe = APIRecipe(
            id: "2",
            title: "No image",
            instructions: "Cook.",
            imageURL: nil,
            category: nil,
            area: nil,
            ingredients: []
        )

        #expect(!recipe.hasUsableImage)
        /// но не проверяет что изображение по адресу существует
    }

    @Test
    func favoritePreservesAPIRecipe() {
        let recipe = APIRecipe(
            id: "1",
            title: "Soup",
            instructions: "Boil.",
            imageURL: URL(string: "https://example.com/soup.jpg"),
            category: "Starter",
            area: "French",
            ingredients: [Ingredient(name: "Water", measure: "1 l")]
        )

        let favorite = FavoriteRecipe(recipe: recipe)

        #expect(favorite.apiRecipe == recipe)
    }
}
