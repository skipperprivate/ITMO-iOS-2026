//
//  DateParser.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

enum DateParser {
    // ISO 8601 формат, который обычно присылает бэкенд
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    // Fallback без миллисекунд
    private static let isoFormatterNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static func parse(_ string: String) -> Date {
        return isoFormatter.date(from: string)
            ?? isoFormatterNoFraction.date(from: string)
            ?? Date() // Fallback на текущую дату, если совсем ничего не подошло
    }
}
