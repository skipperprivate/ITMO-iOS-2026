//
//  MealType.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import Foundation

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case dinner
    case snack

    var title: String {
        switch self {
        case .breakfast: "Завтрак"
        case .lunch: "Обед"
        case .dinner: "Ужин"
        case .snack: "Перекус"
        }
    }
}
