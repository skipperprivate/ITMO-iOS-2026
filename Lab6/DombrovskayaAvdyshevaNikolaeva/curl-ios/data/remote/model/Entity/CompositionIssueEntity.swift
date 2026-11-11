//
//  CompositionIssueEntity.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation
import SwiftData

@Model
class CompositionIssueEntity {
    var ingredient: String?
    var category: String?
    var reason: String?
    
    // Обратная связь
    var analysis: CompositionAnalysisEntity?
    
    init(ingredient: String? = nil, category: String? = nil, reason: String? = nil) {
        self.ingredient = ingredient
        self.category = category
        self.reason = reason
    }
}
