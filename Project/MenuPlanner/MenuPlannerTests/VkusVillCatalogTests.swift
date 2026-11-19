import XCTest
@testable import MenuPlanner

@MainActor
final class VkusVillCatalogTests: CatalogTestCase {
    func testSearchPerformsHandshakeAndDeduplicatesPositiveProductIDs() async throws {
        serveTool(["items": [["id": 1, "name": "Рис"], ["id": 1, "name": "Дубликат"],
                             ["id": 0, "name": "Неверный"], ["id": -1, "name": "Неверный"],
                             ["id": 2, "name": "Молоко"]]])
        let result = try await catalog.search("рис")
        XCTAssertEqual(result.map(\.id), [1, 2])
        let requests = StubURLProtocol.requests
        XCTAssertEqual(requests.count, 3)
        let initBody = try Self.body(of: requests[0])
        XCTAssertEqual(initBody["method"] as? String, "initialize")
        XCTAssertEqual(initBody["jsonrpc"] as? String, "2.0")
        XCTAssertNil(try Self.body(of: requests[1])["id"])
        XCTAssertEqual(try Self.body(of: requests[1])["method"] as? String, "notifications/initialized")
        XCTAssertEqual(requests[2].httpMethod, "POST")
        XCTAssertEqual(requests[2].url?.absoluteString, "https://mcp.vkusvill.ru/mcp")
        XCTAssertEqual(requests[2].value(forHTTPHeaderField: "Mcp-Session-Id"), "test-session")
        XCTAssertEqual(requests[2].value(forHTTPHeaderField: "MCP-Protocol-Version"), "2025-06-18")
        XCTAssertEqual(requests[2].value(forHTTPHeaderField: "Content-Type"), "application/json")
        let params = try XCTUnwrap(try Self.body(of: requests[2])["params"] as? [String: Any])
        XCTAssertEqual(params["name"] as? String, "vkusvill_products_search")
        let args = try XCTUnwrap(params["arguments"] as? [String: Any])
        XCTAssertEqual(args["q"] as? String, "рис")
        XCTAssertEqual(args["limit"] as? Int, 10)
    }

    func testServerSentEventsAreDecodedDespiteUnrelatedLines() async throws {
        serveTool(["items": [["id": 1, "name": "Рис"]]], sse: true)
        let result = try await catalog.search("рис")
        XCTAssertEqual(result.first?.name, "Рис")
    }

    func testRecipeSearchSendsPageAndDecodesSnakeCaseMetadata() async throws {
        serveTool(["items": [recipeJSON()], "meta": ["has_more": true]])
        let page = try await catalog.searchRecipes("каша", page: 3)
        XCTAssertEqual(page.items.map(\.id), [1])
        XCTAssertTrue(page.meta.hasMore)
        let body = try Self.body(of: XCTUnwrap(StubURLProtocol.requests.last))
        let params = try XCTUnwrap(body["params"] as? [String: Any])
        let args = try XCTUnwrap(params["arguments"] as? [String: Any])
        XCTAssertEqual(args["page"] as? Int, 3)
        XCTAssertEqual(args["q"] as? String, "каша")
        XCTAssertEqual(Set(args.keys), [
            "q", "page", "sort", "id_feature_filter", "id_cooking_time_filter",
            "id_cooking_method_filter", "id_complexity_filter", "id_category_filter", "id_exclude_allergens_filter"
        ])
        XCTAssertEqual(args["sort"] as? String, "popularity")
        XCTAssertEqual(args["id_exclude_allergens_filter"] as? [Int], [])
    }

    func testProductDetailsSendsRequestedID() async throws {
        serveTool(["id": 42, "name": "Молоко"])
        let product = try await catalog.product(id: 42)
        XCTAssertEqual(product.id, 42)
        let body = try Self.body(of: XCTUnwrap(StubURLProtocol.requests.last))
        let params = try XCTUnwrap(body["params"] as? [String: Any])
        XCTAssertEqual(params["name"] as? String, "vkusvill_product_details")
        XCTAssertEqual((params["arguments"] as? [String: Any])?["id"] as? Int, 42)
    }

    func testHTTPFailureAndMalformedInitializationAreRejected() async {
        for reply in [StubURLProtocol.Reply(status: 503, data: Data()),
                      .init(data: Data("not JSON".utf8)),
                      .init(data: Data(#"{"error":{"code":-1}}"#.utf8)),
                      .init(data: Data(#"{"result":null}"#.utf8))] {
            StubURLProtocol.configure { _ in reply }
            do { _ = try await catalog.search("рис"); XCTFail("Expected failure") }
            catch { XCTAssertTrue(error is URLError) }
        }
    }

    func testToolErrorsMissingContentAndInvalidPayloadAreRejected() async throws {
        let badResults: [[String: Any]] = [
            ["isError": true, "content": [["type": "text", "text": "{}"]]],
            ["content": []], ["content": [["type": "image", "text": "{}"]]],
            ["content": [["type": "text"]]],
            ["content": [["type": "text", "text": "invalid JSON"]]],
            ["content": [["type": "text", "text": #"{"ok":false}"#]]],
            ["content": [["type": "text", "text": #"{"ok":true,"data":null}"#]]]
        ]
        for result in badResults {
            StubURLProtocol.configure { request in
                let body = try Self.body(of: request)
                if body["method"] as? String == "initialize" {
                    return .init(data: Data(#"{"result":{"protocolVersion":"2025-06-18"}}"#.utf8))
                }
                if body["method"] as? String == "notifications/initialized" { return .init(data: Data()) }
                return .init(data: try JSONSerialization.data(withJSONObject: ["result": result]))
            }
            do { _ = try await catalog.search("рис"); XCTFail("Expected failure for \(result)") }
            catch { /* Any decoding/server error is a failure, never an empty successful result. */ }
        }
    }

    func testTransportErrorIsPropagated() async {
        do { _ = try await catalog.search("рис"); XCTFail("Expected failure") }
        catch { XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet) }
    }

    func testAlreadyCancelledRequestDoesNotStartHTTP() async {
        let task = Task { try await catalog.search("рис") }
        task.cancel()
        do { _ = try await task.value; XCTFail("Expected cancellation") }
        catch { XCTAssertTrue(error is CancellationError) }
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testCartRejectsInvalidCountsIDsAndQuantitiesBeforeHTTP() async {
        let bad: [[VkusVillCatalog.CartItem]] = [
            [], Array(repeating: .init(id: 1, quantity: 1), count: 101),
            [.init(id: 0, quantity: 1)], [.init(id: -1, quantity: 1)],
            [.init(id: 1, quantity: 0)], [.init(id: 1, quantity: 0.009)],
            [.init(id: 1, quantity: 40.01)], [.init(id: 1, quantity: .nan)], [.init(id: 1, quantity: .infinity)]
        ]
        for items in bad {
            do { _ = try await catalog.createCartLink(items: items); XCTFail("Expected rejection") }
            catch { XCTAssertEqual((error as? URLError)?.code, .badURL) }
        }
        XCTAssertTrue(StubURLProtocol.requests.isEmpty)
    }

    func testCartAcceptsBoundaryAmountsAndSerializesProducts() async throws {
        serveTool(["link": "https://vkusvill.ru/cart/test"])
        let items = [VkusVillCatalog.CartItem(id: 1, quantity: 0.01), .init(id: 2, quantity: 40)]
        let url = try await catalog.createCartLink(items: items)
        XCTAssertEqual(url.absoluteString, "https://vkusvill.ru/cart/test")
        let body = try Self.body(of: XCTUnwrap(StubURLProtocol.requests.last))
        let params = try XCTUnwrap(body["params"] as? [String: Any])
        let arguments = try XCTUnwrap(params["arguments"] as? [String: Any])
        let products = try XCTUnwrap(arguments["products"] as? [[String: Any]])
        XCTAssertEqual(products.compactMap { $0["id"] as? Int }, [1, 2])
        XCTAssertEqual(products.compactMap { $0["q"] as? Double }, [0.01, 40])
    }

    func testCartAcceptsOneHundredProducts() async throws {
        serveTool(["link": "https://vkusvill.ru/cart/test"])
        _ = try await catalog.createCartLink(items: (1...100).map { .init(id: $0, quantity: 1) })
        XCTAssertEqual(StubURLProtocol.requests.count, 3)
    }

    func testCartRejectsUnofficialOrInsecureReturnedLinks() async {
        for link in ["http://vkusvill.ru/cart", "https://evil.example/cart", "https://vkusvill.ru.evil.example/cart"] {
            serveTool(["link": link])
            do {
                _ = try await catalog.createCartLink(items: [.init(id: 1, quantity: 1)])
                XCTFail("Expected rejection")
            }
            catch { XCTAssertEqual((error as? URLError)?.code, .badServerResponse) }
        }
    }

    func testPhotoAcceptsNonemptyImageAtSizeLimit() async throws {
        let data = Data(repeating: 1, count: 10_000_000)
        StubURLProtocol.configure { _ in .init(headers: ["Content-Type": "image/jpeg"], data: data) }
        let actual = try await catalog.recipePhoto(from: URL(string: "https://vkusvill.ru/photo.jpg")!)
        XCTAssertEqual(actual, data)
    }

    func testPhotoRejectsHTTPFailureWrongMIMEEmptyAndOversizedData() async {
        let replies: [StubURLProtocol.Reply] = [
            .init(status: 404, headers: ["Content-Type": "image/png"], data: Data([1])),
            .init(headers: ["Content-Type": "text/html"], data: Data([1])),
            .init(headers: [:], data: Data([1])),
            .init(headers: ["Content-Type": "image/png"], data: Data()),
            .init(headers: ["Content-Type": "image/png"], data: Data(repeating: 1, count: 10_000_001))
        ]
        for reply in replies {
            StubURLProtocol.configure { _ in reply }
            do { _ = try await catalog.recipePhoto(from: URL(string: "https://vkusvill.ru/photo")!); XCTFail("Expected rejection") }
            catch { XCTAssertEqual((error as? URLError)?.code, .badServerResponse) }
        }
    }
}
