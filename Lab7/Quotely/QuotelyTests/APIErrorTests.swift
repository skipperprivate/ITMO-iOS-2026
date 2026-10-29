//
//  APIErrorTests.swift
//  QuotelyTests
//
//  Created by Egor Kuzminykh on 22.10.2026.
//

import XCTest
@testable import Quotely

final class APIErrorTests: XCTestCase {

    func testTimedOutHasReadableDescription() {
        let error = APIError.timedOut

        let message = error.localizedDescription

        XCTAssertEqual(message, "Сервер не ответил вовремя. Повторите попытку.")
    }

    func testHTTPErrorTextDependsOnStatusCode() {
        let serverSide = APIError.http(status: 503, message: nil)
        let clientSide = APIError.http(status: 404, message: "Not found")

        let serverMessage = serverSide.localizedDescription
        let clientMessage = clientSide.localizedDescription

        XCTAssertTrue(serverMessage.contains("Сервер временно недоступен"))
        XCTAssertTrue(serverMessage.contains("503"), "В тексте должен быть сам код ответа")

        XCTAssertTrue(clientMessage.contains("Запрос не принят"))
        XCTAssertTrue(clientMessage.contains("Not found"), "Текст от сервера не должен теряться")
    }
}
