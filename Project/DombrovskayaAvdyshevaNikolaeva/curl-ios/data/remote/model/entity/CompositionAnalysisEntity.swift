import Foundation
import SwiftData

@Model
class CompositionAnalysisEntity {
    @Attribute(.unique) var id: UUID
    var status: String?
    var ok: Bool?
    var rawTextExcerpt: String?
    var issuesCount: Int?
    var result: String?
    var dateCreated: Date
    
    @Relationship(deleteRule: .cascade) var issues: [CompositionIssueEntity]?
    
    init(id: UUID = UUID(), status: String? = nil, ok: Bool? = nil, rawTextExcerpt: String? = nil, issuesCount: Int? = nil, result: String? = nil, dateCreated: Date = Date()) {
        self.id = id
        self.status = status
        self.ok = ok
        self.rawTextExcerpt = rawTextExcerpt
        self.issuesCount = issuesCount
        self.result = result
        self.dateCreated = dateCreated
    }
}
