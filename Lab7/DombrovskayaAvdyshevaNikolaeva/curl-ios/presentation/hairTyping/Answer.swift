//
//  Answer.swift
//  curl-ios
//
//  Created by Nadineenik on 19.10.2026.
//

import Foundation

struct Answer: Identifiable {
    let id = UUID()
    let result: String
    let text: String
}

enum PorosityTypes: String {
    case porous = "p"
    case semiPorous = "s"
    case nonPorous = "n"
    
    var dbCode: String {
        switch self {
        case .porous: return "HIGH"
        case .semiPorous: return "MEDIUM"
        case .nonPorous: return "LOW"
        }
    }
    
    var resultName: String {
        switch self {
        case .porous: return "пористые"
        case .semiPorous: return "среднепористые"
        case .nonPorous: return "низкопористые"
        }
    }
}

enum ColoredTypes: String {
    case colored = "c"
    case notColored = "n"
    
    var resultName: String {
        switch self {
        case .colored: return "окрашенные"
        case .notColored: return "неокрашенные"
        }
    }
}


enum ThicknessTypes: String, CaseIterable {
    case thin = "t"
    case medium = "m"
    case bold = "b"
    
    var dbCode: String {
        switch self {
        case .thin: return "THIN"
        case .medium: return "MEDIUM"
        case .bold: return "THICK"
        }
    }
    
    var resultName: String {
        switch self {
        case .thin: return "тонкие"
        case .medium: return "средние"
        case .bold: return "толстые"
        }
    }
    
    static func getResultNameByDbCode(_ dbCode: String) -> String? {
        return Self.allCases
            .first { $0.dbCode == dbCode }?
            .resultName
            .capitalized
    }
    
    static func getDbCodeByResultName(_ resultName: String) -> String? {
        return Self.allCases
            .first { $0.resultName == resultName }?
            .dbCode
            .capitalized
    }
}
