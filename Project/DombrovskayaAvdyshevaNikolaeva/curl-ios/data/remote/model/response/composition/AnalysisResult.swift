import Foundation

struct AnalysisResponse: Codable {
    let status: String?
    let result: AnalysisResult?
}

struct AnalysisResult: Codable {
    let ok: Bool?
    let rawTextExcerpt: String?
    let issuesCount: Int?
    let issues: [AnalysisIssue]?
    let result: String?
    
    enum CodingKeys: String, CodingKey {
        case ok
        case rawTextExcerpt = "raw_text_excerpt"
        case issuesCount = "issues_count"
        case issues
        case result
    }
}
