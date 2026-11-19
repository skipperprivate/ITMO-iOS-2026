import XCTest
@testable import MenuPlanner

@MainActor
final class VkusVillSearchViewModelTests: CatalogTestCase {
    func testBlankSearchRemainsIdleWithoutHTTP() async {
        let model = VkusVillSearchViewModel(catalog: catalog)
        await model.search(" \n ")
        guard case .idle = model.state else { return XCTFail("Expected idle") }
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testSearchSuccessEmptyResultsAndRetryAfterFailure() async {
        let model = VkusVillSearchViewModel(catalog: catalog)
        await model.search("рис")
        guard case .failed = model.state else { return XCTFail("Expected failed state") }
        serveTool(["items": [["id": 1, "name": "Рис"]]])
        await model.search("  рис  ")
        guard case .results(let products) = model.state else { return XCTFail("Expected results") }
        XCTAssertEqual(products.map(\.id), [1])
        serveTool(["items": []])
        await model.search("пусто")
        guard case .results(let empty) = model.state else { return XCTFail("Expected empty results") }
        XCTAssertTrue(empty.isEmpty)
        await model.search("")
        guard case .idle = model.state else { return XCTFail("Clearing query should restore idle") }
    }

    func testSuggestionsLoadOnlyFirstThreeAndSkipFailures() async throws {
        StubURLProtocol.configure { request in
            let body = try Self.body(of: request)
            if body["method"] as? String == "initialize" {
                return .init(data: Data(#"{"result":{"protocolVersion":"2025-06-18"}}"#.utf8))
            }
            if body["method"] as? String == "notifications/initialized" { return .init(data: Data()) }
            let args = (body["params"] as? [String: Any])?["arguments"] as? [String: Any]
            let id = args?["id"] as? Int ?? 0
            if id == 2 { throw URLError(.timedOut) }
            let payload: [String: Any] = ["ok": true, "data": ["id": id, "name": "Товар"]]
            let text = String(decoding: try JSONSerialization.data(withJSONObject: payload), as: UTF8.self)
            return .init(data: try JSONSerialization.data(withJSONObject: ["result": ["content": [["type": "text", "text": text]]]]))
        }
        let model = VkusVillSearchViewModel(catalog: catalog)
        await model.loadSuggestions([1, 2, 3, 4])
        XCTAssertEqual(model.suggestions.map(\.id), [1, 3])
        XCTAssertEqual(StubURLProtocol.requests.count, 9)
        await model.loadSuggestions([])
        XCTAssertTrue(model.suggestions.isEmpty)
    }

    func testCancelledOldSearchDoesNotOverwriteNewIdleState() async {
        let started = expectation(description: "Search started")
        StubURLProtocol.configure { _ in
            started.fulfill()
            return .init(data: Data(#"{"result":{"protocolVersion":"2025-06-18"}}"#.utf8), delay: 1)
        }
        let model = VkusVillSearchViewModel(catalog: catalog)
        let task = Task { await model.search("рис") }
        await fulfillment(of: [started], timeout: 3)
        await model.search("")
        task.cancel()
        await task.value
        guard case .idle = model.state else { return XCTFail("Cancelled request overwrote new state") }
    }

    func testAlreadyCancelledSearchAndSuggestionsDoNotStartNetwork() async {
        let model = VkusVillSearchViewModel(catalog: catalog)
        let search = Task { await model.search("рис") }
        search.cancel()
        await search.value
        let suggestions = Task { await model.loadSuggestions([1]) }
        suggestions.cancel()
        await suggestions.value
        guard case .idle = model.state else { return XCTFail("Expected idle") }
        XCTAssertTrue(model.suggestions.isEmpty)
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }
}
