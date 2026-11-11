import Foundation
import SwiftData

@Model
class CompositionIssueEntity {
    var ingredient: String?
    var category: String?
    var reason: String?
    
    var analysis: CompositionAnalysisEntity?
    
    init(ingredient: String? = nil, category: String? = nil, reason: String? = nil) {
        self.ingredient = ingredient
        self.category = category
        self.reason = reason
    }
}
