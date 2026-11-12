//
//  APIErrorTests.swift
//  QuotelyTests
//
//  Created by Egor Kuzminykh on 22.10.2026.
//

@testable import Quotely
import XCTest

final class APIErrorTests: XCTestCase {
    func testTimedOutHasReadableDescription() {
        let error = APIError.timedOut

        let message = error.localizedDescription

        XCTAssertFalse(message.isEmpty)
    }

    func testHTTPErrorTextDependsOnStatusCode() {
        let serverSide = APIError.http(status: 503, message: nil)
        let clientSide = APIError.http(status: 404, message: "Not found")

        let serverMessage = serverSide.localizedDescription
        let clientMessage = clientSide.localizedDescription

        XCTAssertTrue(serverMessage.contains("503"), "В тексте должен быть сам код ответа")

        XCTAssertTrue(clientMessage.contains("Not found"), "Текст от сервера не должен теряться")
    }
}
