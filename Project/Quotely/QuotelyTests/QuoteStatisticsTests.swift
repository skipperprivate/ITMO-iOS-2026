//
//  QuoteStatisticsTests.swift
//  QuotelyTests
//
//  Created by Egor Kuzminykh on 22.10.2026.
//

import XCTest
@testable import Quotely

@MainActor
final class QuoteStatisticsTests: XCTestCase {

    func testEmptyListGivesZeroStatistics() async {
        let statistics = await QuoteStatistics.calculate(for: [])

        XCTAssertEqual(statistics.total, 0)
        XCTAssertEqual(statistics.favorites, 0)
        XCTAssertEqual(statistics.authors, 0)
        XCTAssertEqual(statistics.averageLength, 0)
    }

    func testStatisticsCountsFavoritesAndUniqueAuthors() async {
        let quotes = [
            Quote(text: "1234", author: "Пушкин", isFavorite: true),
            Quote(text: "123456", author: "Пушкин", isFavorite: false),
            Quote(text: "12345678", author: "Есенин", isFavorite: true)
        ]

        let statistics = await QuoteStatistics.calculate(for: quotes)

        XCTAssertEqual(statistics.total, 3)
        XCTAssertEqual(statistics.favorites, 2)
        XCTAssertEqual(statistics.authors, 2, "Пушкин встречается дважды, а считается один раз")
        XCTAssertEqual(statistics.averageLength, 6, "(4 + 6 + 8) / 3 = 6")
    }
}
