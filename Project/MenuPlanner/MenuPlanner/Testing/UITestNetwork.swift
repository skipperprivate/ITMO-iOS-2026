#if DEBUG
import Foundation

// Enabled only by the UI test launcher. Release builds contain no fixtures.
enum UITestNetwork {
    static func session() -> URLSession? {
        guard ProcessInfo.processInfo.arguments.contains("--ui-testing") else { return nil }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [UITestURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

nonisolated private final class UITestURLProtocol: URLProtocol {
    private static let lock = NSLock()
    private static var attempts: [String: Int] = [:]

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        do {
            let body = try requestBody()
            let method = body["method"] as? String
            if method == "initialize" {
                try respond(["result": ["protocolVersion": "2025-06-18"]])
                return
            }
            if method == "notifications/initialized" {
                try respond([:])
                return
            }
            let params = body["params"] as? [String: Any] ?? [:]
            let tool = params["name"] as? String ?? ""
            let arguments = params["arguments"] as? [String: Any] ?? [:]
            let query = arguments["q"] as? String ?? ""
            let key = "\(tool):\(query)"
            let attempt = Self.lock.withLock {
                Self.attempts[key, default: 0] += 1
                return Self.attempts[key, default: 0]
            }
            let scenario = ProcessInfo.processInfo.environment["MENU_PLANNER_NETWORK_SCENARIO"]
            if scenario == "offline" || (scenario == "retry" && attempt == 1) {
                try respond([:], status: 503)
                return
            }
            let product: [String: Any] = ["id": 101, "name": "Рис тестовый 500 г", "unit": "шт",
                                          "weight": ["value": 500, "unit": "г"], "price": ["current": 100],
                                          "url": "https://vkusvill.ru/goods/ui-test"]
            let payload: [String: Any]
            switch tool {
            case "vkusvill_products_search":
                payload = ["items": query == "ничего" ? [] : [product]]
            case "vkusvill_product_details":
                payload = product
            case "vkusvill_recipes":
                let page = arguments["page"] as? Int ?? 1
                let recipe: [String: Any] = [
                    "id": page == 1 ? 201 : 202,
                    "name": page == 1 ? "Каша из каталога" : "Суп из каталога",
                    "url": "https://vkusvill.ru/recipes/ui-test", "portions": 2,
                    "cooking_time": ["name": "30 минут"],
                    "ingredients": [["name": "Рис", "quantity": "100 г", "ids": ["101"]]],
                    "steps": [["step_number": 1, "text": "Сварить рис."]]
                ]
                payload = ["items": query == "ничего" ? [] : [recipe], "meta": ["has_more": page == 1]]
            case "vkusvill_cart_link_create":
                payload = ["link": "https://vkusvill.ru/cart/ui-test"]
            default:
                throw URLError(.unsupportedURL)
            }
            let data = try JSONSerialization.data(withJSONObject: ["ok": true, "data": payload])
            try respond(["result": ["content": [["type": "text", "text": String(decoding: data, as: UTF8.self)]]]])
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }

    private func respond(_ json: [String: Any], status: Int = 200) throws {
        let data = try JSONSerialization.data(withJSONObject: json)
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json", "Mcp-Session-Id": "ui-test"])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    private func requestBody() throws -> [String: Any] {
        var data = request.httpBody ?? Data()
        if data.isEmpty, let stream = request.httpBodyStream {
            stream.open()
            defer { stream.close() }
            var buffer = [UInt8](repeating: 0, count: 4_096)
            while stream.hasBytesAvailable {
                let count = stream.read(&buffer, maxLength: buffer.count)
                if count <= 0 { break }
                data.append(buffer, count: count)
            }
        }
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
}
#endif
