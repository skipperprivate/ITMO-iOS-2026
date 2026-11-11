//
//  LocalDateTimeParser.swift
//  curl-ios
//
//  Created by Nadineenik on 05.10.2026.
//

import Foundation

enum LocalDateTimeParser {
    // Формат: "2026-10-05T14:30:00" или "2026-10-05T14:30:00.123"
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" // с микросекундами
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC") // ПРЕДПОЛАГАЕМ, что сервер отдает UTC
        return formatter
    }()
    
    private static let formatterNoMillis: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC") // ПРЕДПОЛАГАЕМ, что сервер отдает UTC
        return formatter
    }()
    
    static func parse(_ string: String) -> Date? {
        return formatter.date(from: string)
            ?? formatterNoMillis.date(from: string)
    }
}
