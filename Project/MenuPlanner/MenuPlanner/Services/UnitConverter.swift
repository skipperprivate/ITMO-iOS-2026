//
//  UnitConverter.swift
//  MenuPlanner
//
//  Created by FergeS on 31/10/2026.
//
import Foundation

struct UnitConverter {
    
    func normalize(quantity: Double, unit: MeasurementUnit) -> (quantity: Double, unit: MeasurementUnit) {
        switch unit {
            case .kilogram: return (quantity * 1000, .gram)
            case .liter: return (quantity * 1000, .milliliter)
            default: return (quantity, unit)
        }
    }
}
