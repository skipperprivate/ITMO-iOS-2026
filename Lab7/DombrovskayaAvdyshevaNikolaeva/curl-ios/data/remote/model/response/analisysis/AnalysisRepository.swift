//
//  AnalysisRepository.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

protocol AnalysisRepository {
    func analyzePhoto(imageData: Data) async throws -> String
}
