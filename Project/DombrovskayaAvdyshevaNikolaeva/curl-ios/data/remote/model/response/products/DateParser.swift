import Foundation

enum DateParser {
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    private static let isoFormatterNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static func parse(_ string: String) -> Date {
        return isoFormatter.date(from: string)
            ?? isoFormatterNoFraction.date(from: string)
            ?? Date()
    }
}
