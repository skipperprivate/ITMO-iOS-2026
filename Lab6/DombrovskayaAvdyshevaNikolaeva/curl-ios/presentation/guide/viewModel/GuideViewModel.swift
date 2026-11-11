//
//  GuideViewModel.swift
//  curl-ios
//
//  Created by Nadineenik on 12.10.2026.
//

import SwiftUI

@MainActor
final class GuideViewModel: ObservableObject {
    @Published var sections: [GuideSection] = []
    @Published var expandedSections: Set<UUID> = []
    
    init() {
        loadGuide()
    }
    
    func loadGuide() {
        let text = GuideParser.loadGuide()
        sections = GuideParser.parseSections(from: text)
    }
    
    func toggleSection(_ section: GuideSection) {
        if expandedSections.contains(section.id) {
            expandedSections.remove(section.id)
        } else {
            expandedSections.insert(section.id)
        }
    }
    
    func isExpanded(_ section: GuideSection) -> Bool {
        expandedSections.contains(section.id)
    }
}
