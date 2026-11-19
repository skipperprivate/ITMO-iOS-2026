import Foundation
import XCTest
@testable import MenuPlanner

// Every request is intercepted, including failure cases. No test uses the live service.
final class StubURLProtocol: URLProtocol {
    struct Reply {
        var status = 200
        var headers = ["Content-Type": "application/json"]
        var data: Data
        var delay: TimeInterval = 0
    }

    private static let lock = NSLock()
    private static var handler: ((URLRequest) throws -> Reply)?
    private static var recorded: [URLRequest] = []
    private let deliveryLock = NSLock()
    private var stopped = false

    static var requests: [URLRequest] { lock.withLock { recorded } }

    static func configure(_ handler: @escaping (URLRequest) throws -> Reply) {
        lock.withLock {
            self.handler = handler
            recorded = []
        }
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let callback = Self.lock.withLock {
            Self.recorded.append(request)
            return Self.handler
        }
        do {
            guard let callback else { throw URLError(.resourceUnavailable) }
            let reply = try callback(request)
            let deliver = { [self] in
                deliveryLock.withLock {
                    guard !stopped else { return }
                    let response = HTTPURLResponse(url: request.url!, statusCode: reply.status,
                                                   httpVersion: nil, headerFields: reply.headers)!
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    client?.urlProtocol(self, didLoad: reply.data)
                    client?.urlProtocolDidFinishLoading(self)
                }
            }
            if reply.delay > 0 {
                DispatchQueue.global().asyncAfter(deadline: .now() + reply.delay, execute: deliver)
            } else {
                deliver()
            }
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { deliveryLock.withLock { stopped = true } }
}

@MainActor
class CatalogTestCase: XCTestCase {
    var session: URLSession!
    var catalog: VkusVillCatalog!

    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        session = URLSession(configuration: configuration)
        catalog = VkusVillCatalog(session: session)
        StubURLProtocol.configure { _ in throw URLError(.notConnectedToInternet) }
    }

    override func tearDownWithError() throws {
        session.invalidateAndCancel()
        session = nil
        catalog = nil
        StubURLProtocol.configure { _ in throw URLError(.notConnectedToInternet) }
    }

    func serveTool(_ payload: Any, sse: Bool = false,
                   observe: (([String: Any]) -> Void)? = nil) {
        StubURLProtocol.configure { request in
            let body = try Self.body(of: request)
            if body["method"] as? String == "initialize" {
                let data = try JSONSerialization.data(withJSONObject: ["result": ["protocolVersion": "2025-06-18"]])
                return .init(headers: ["Mcp-Session-Id": "test-session"], data: data)
            }
            if body["method"] as? String == "notifications/initialized" {
                return .init(status: 202, data: Data())
            }
            observe?(body)
            let text = String(decoding: try JSONSerialization.data(withJSONObject: ["ok": true, "data": payload]), as: UTF8.self)
            let response: [String: Any] = ["result": ["content": [["type": "text", "text": text]]]]
            let data = try JSONSerialization.data(withJSONObject: response)
            if sse {
                return .init(headers: ["Content-Type": "text/event-stream"],
                             data: Data("event: message\ndata: invalid\ndata: \(String(decoding: data, as: UTF8.self))\n\n".utf8))
            }
            return .init(data: data)
        }
    }

    nonisolated static func body(of request: URLRequest) throws -> [String: Any] {
        var data = request.httpBody
        if data == nil, let stream = request.httpBodyStream {
            stream.open()
            defer { stream.close() }
            var collected = Data()
            var buffer = [UInt8](repeating: 0, count: 4_096)
            while stream.hasBytesAvailable {
                let count = stream.read(&buffer, maxLength: buffer.count)
                if count <= 0 { break }
                collected.append(buffer, count: count)
            }
            data = collected
        }
        return try JSONSerialization.jsonObject(with: XCTUnwrap(data)) as! [String: Any]
    }

    func product(_ id: Int = 1, name: String = "Рис", unit: String = "шт",
                 weight: VkusVillProduct.Weight? = .init(value: 500, unit: "г")) -> VkusVillProduct {
        VkusVillProduct(id: id, name: name, price: nil, unit: unit, weight: weight, url: nil, images: nil)
    }

    func recipeJSON(_ id: Int = 1) -> [String: Any] { ["id": id, "name": "Каша \(id)"] }

    func importedRecipe(_ json: String) throws -> VkusVillRecipe {
        try JSONDecoder().decode(VkusVillRecipe.self, from: Data(json.utf8))
    }
}
