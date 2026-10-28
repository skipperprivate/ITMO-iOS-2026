import XCTest
import Foundation
#if SWIFT_PACKAGE
@testable import NewsLabCore
#else
@testable import app
#endif

private actor RecordingTransport: HTTPTransport {
    private(set) var request: URLRequest?
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        self.request = request
        let json = #"{"id":251,"title":"Server title","body":"Server body","userId":7}"#
        return (Data(json.utf8), HTTPURLResponse(url: request.url!, statusCode: 201, httpVersion: nil, headerFields: nil)!)
    }
}

private struct TimeoutTransport: HTTPTransport {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.timedOut)
    }
}

@MainActor
final class NewsNetworkTests: XCTestCase {
    func testCreateSendsTrimmedJSONAndReturnsServerArticle() async throws {
        let transport = RecordingTransport()
        let client = NewsAPIClient(transport: transport)
        let result = try await client.create(NewPost(title: "  Draft title ", body: " Draft body\n", userId: 7))
        let recorded = await transport.request
        let request = try XCTUnwrap(recorded)
        XCTAssertEqual(request.url?.absoluteString, "https://dummyjson.com/posts/add")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        let body = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(request.httpBody)) as? [String: Any])
        XCTAssertEqual(body["title"] as? String, "Draft title")
        XCTAssertEqual(body["body"] as? String, "Draft body")
        XCTAssertEqual(body["userId"] as? Int, 7)
        XCTAssertEqual(result.id, 251)
        XCTAssertEqual(result.title, "Server title")
        XCTAssertEqual(result.body, "Server body")
        XCTAssertEqual(result.authorID, 7)
    }

    func testFetchMapsTransportTimeoutToNewsAPIError() async {
        do {
            _ = try await NewsAPIClient(transport: TimeoutTransport()).fetchArticles()
            XCTFail("Ожидалась ошибка тайм-аута")
        } catch NewsAPIError.timeout {
            // Ожидаемая прикладная ошибка.
        } catch {
            XCTFail("Неожиданная ошибка: \(error)")
        }
    }
}
