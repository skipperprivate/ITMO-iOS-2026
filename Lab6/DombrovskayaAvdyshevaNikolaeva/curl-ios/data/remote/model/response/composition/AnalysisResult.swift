//
//  AnalysisResult.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

//high-level response
struct AnalysisResponse: Codable {
    let status:  String?
    let result: AnalysisResult?
}

//main analyze result
struct AnalysisResult: Codable {
    let ok: Bool?
    let rawTextExcerpt: String?
    let issuesCount: Int?
    let issues: [AnalysisIssue]?
    let result: String?
    
    //маппинг snake_case из JSON в camelCase Swift
    enum CodingKeys: String, CodingKey{
        case ok
        case rawTextExcerpt = "raw_text_excerpt"
        case issuesCount = "issues_count"
        case issues
        case result
    }
}
