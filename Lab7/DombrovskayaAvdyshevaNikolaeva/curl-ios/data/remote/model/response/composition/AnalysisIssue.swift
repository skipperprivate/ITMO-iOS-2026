//
//  AnalysisIssue.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

//Вложенная модель проблемы
struct AnalysisIssue: Codable {
    let ingredient: String?
    let category: String?
    let reason: String?
}
