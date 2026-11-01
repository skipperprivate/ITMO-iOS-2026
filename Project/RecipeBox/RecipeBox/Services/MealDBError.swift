//
//  MealDBError.swift
//  RecipeBox
//
//  Created by nktmahov on 07.10.26.
//

import Foundation

enum MealDBError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noRecipes

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Не удалось сформировать адрес запроса."
        case .invalidResponse:
            "Сервис рецептов вернул некорректный ответ."
        case .noRecipes:
            "Рецепты не найдены."
        }
    }
}
