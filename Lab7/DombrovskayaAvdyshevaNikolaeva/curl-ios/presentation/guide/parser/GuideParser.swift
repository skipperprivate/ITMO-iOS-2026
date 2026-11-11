//
//  GuideParser.swift
//  curl-ios
//
//  Created by Nadineenik on 12.10.2026.
//

import Foundation

struct GuideSection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let content: String
}

enum GuideParser {
    
    static func loadGuide(named fileName: String = "guide_detailed") -> String {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return "Ошибка загрузки гайда"
        }
        return text
    }
    
    static func parseSections(from text: String) -> [GuideSection] {
        var sections: [GuideSection] = []
        var currentTitle: String?
        var currentContent: [String] = []
        
        for line in text.components(separatedBy: .newlines) {
            if line.hasPrefix("#") {
                // Сохраняем предыдущую секцию
                if let title = currentTitle {
                    sections.append(GuideSection(
                        title: title,
                        content: currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    ))
                }
               
                currentTitle = line
                    .replacingOccurrences(of: "# ", with: "")
                    .trimmingCharacters(in: .whitespaces)
                currentContent = []
            } else {
                currentContent.append(line)
            }
        }
        
        if let title = currentTitle {
            sections.append(GuideSection(
                title: title,
                content: currentContent.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            ))
        }
        
        return sections
    }
}
