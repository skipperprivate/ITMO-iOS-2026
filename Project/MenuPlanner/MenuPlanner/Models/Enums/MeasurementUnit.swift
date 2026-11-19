//
//  MeasurementUnit.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import Foundation

enum MeasurementUnit: String, Codable, CaseIterable {
    case gram
    case kilogram
    case milliliter
    case liter
    case piece
    case teaspoon
    case tablespoon
    
    var title: String {
        switch self {
        case .gram: return "г"
        case .kilogram: return "кг"
        case .milliliter: return "мл"
        case .liter: return "л"
        case .piece: return "шт"
        case .teaspoon: return "ч.л"
        case .tablespoon: return "ст.л"
        }
    }
}
