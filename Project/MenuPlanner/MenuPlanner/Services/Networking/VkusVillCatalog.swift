import Foundation

struct VkusVillCatalog {
    struct CartItem: Encodable {
        let id: Int
        let q: Double
    }

    private struct ClientInfo: Encodable {
        let name = "MenuPlanner"
        let version = "1.0"
    }

    private struct Initialization: Encodable {
        let protocolVersion = "2025-06-18"
        let capabilities: [String: String] = [:]
        let clientInfo = ClientInfo()
    }

    private struct InitializationResult: Decodable {
        let protocolVersion: String
    }

    private struct Request<Parameters: Encodable>: Encodable {
        let jsonrpc = "2.0"
        let id: Int?
        let method: String
        let params: Parameters?
    }

    private struct Response<Result: Decodable>: Decodable {
        let result: Result?
    }

    private struct ToolCall<Arguments: Encodable>: Encodable {
        let name: String
        let arguments: Arguments
    }

    private struct ToolResult: Decodable {
        struct Content: Decodable {
            let type: String
            let text: String?
        }
        let content: [Content]
        let isError: Bool?
    }

    private struct ToolPayload<Result: Decodable>: Decodable {
        let ok: Bool
        let data: Result?
    }

    private struct SearchArguments: Encodable {
        let q: String
        let limit = 10
        let mode = "custom"
        let fields = ["id", "name", "price", "unit", "weight", "url", "images"]
    }

    private struct SearchResult: Decodable {
        let items: [VkusVillProduct]
    }

    private struct RecipeSearchArguments: Encodable {
        let q: String
        let page: Int
        let sort = "popularity"
        let id_feature_filter = 0
        let id_cooking_time_filter = 0
        let id_cooking_method_filter = 0
        let id_complexity_filter = 0
        let id_category_filter = 0
        let id_exclude_allergens_filter: [Int] = []
    }

    struct RecipePage: Decodable {
        struct Metadata: Decodable {
            let hasMore: Bool
        }

        let items: [VkusVillRecipe]
        let meta: Metadata
    }

    private struct ProductArguments: Encodable {
        let id: Int
    }

    private struct CartArguments: Encodable {
        let products: [CartItem]
    }

    private struct CartResult: Decodable {
        let link: URL
    }

    private let endpoint = URL(string: "https://mcp.vkusvill.ru/mcp")!
    private let session: URLSession

    init(session: URLSession? = nil) {
        #if DEBUG
        self.session = session ?? UITestNetwork.session() ?? .shared
        #else
        self.session = session ?? .shared
        #endif
    }

    func search(_ query: String) async throws -> [VkusVillProduct] {
        let result: SearchResult = try await call("vkusvill_products_search", arguments: SearchArguments(q: query))
        var seen: Set<Int> = []
        return result.items.filter { $0.id > 0 && seen.insert($0.id).inserted }
    }

    func searchRecipes(_ query: String, page: Int = 1) async throws -> RecipePage {
        try await call("vkusvill_recipes", arguments: RecipeSearchArguments(q: query, page: page))
    }

    func product(id: Int) async throws -> VkusVillProduct {
        try await call("vkusvill_product_details", arguments: ProductArguments(id: id))
    }

    func recipePhoto(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(
            for: URLRequest(url: url, timeoutInterval: 12)
        )
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode),
              response.mimeType?.hasPrefix("image/") == true,
              !data.isEmpty, data.count <= 10_000_000 else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    func createCartLink(items: [CartItem]) async throws -> URL {
        guard (1...100).contains(items.count),
              items.allSatisfy({ $0.id > 0 && (0.01...40).contains($0.q)
        }) else {
            throw URLError(.badURL)
        }

        let result: CartResult = try await call(
            "vkusvill_cart_link_create",
            arguments: CartArguments(products: items)
        )

        guard result.link.scheme == "https",
                result.link.host == "vkusvill.ru"
        else {
            throw URLError(.badServerResponse)
        }

        return result.link
    }

    private func call<Arguments: Encodable, Result: Decodable>(
        _ name: String,
        arguments: Arguments
    ) async throws -> Result {
        let (initData, initResponse) = try await send(
            Request(id: 1, method: "initialize", params: Initialization())
        )

        let initialized: InitializationResult = try decodeResponse(initData)
        let sessionID = initResponse.value(forHTTPHeaderField: "Mcp-Session-Id")

        _ = try await send(
            Request<[String: String]>(id: nil, method: "notifications/initialized", params: nil),
            version: initialized.protocolVersion, sessionID: sessionID
        )

        let (data, _) = try await send(
            Request(id: 2, method: "tools/call", params: ToolCall(name: name, arguments: arguments)),
            version: initialized.protocolVersion, sessionID: sessionID
        )

        let toolResult: ToolResult = try decodeResponse(data)
        guard toolResult.isError != true,
              let payload = toolResult.content.first(where: { $0.type == "text" })?.text else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(ToolPayload<Result>.self, from: Data(payload.utf8))

        guard decoded.ok, let result = decoded.data else {
            throw URLError(.badServerResponse)
        }

        return result
    }

    private func send<Parameters>(
        _ message: Request<Parameters>, version: String? = nil, sessionID: String? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        try Task.checkCancellation()
        var request = URLRequest(url: endpoint, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue(version, forHTTPHeaderField: "MCP-Protocol-Version")
        request.setValue(sessionID, forHTTPHeaderField: "Mcp-Session-Id")
        request.httpBody = try JSONEncoder().encode(message)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return (data, http)
    }

    private func decodeResponse<Result: Decodable>(_ data: Data) throws -> Result {
        let decoder = JSONDecoder()
        if let response = try? decoder.decode(Response<Result>.self, from: data), let result = response.result {
            return result
        }
        for line in String(decoding: data, as: UTF8.self).split(whereSeparator: \.isNewline) {
            guard line.hasPrefix("data:"), let response = try? decoder.decode(
                Response<Result>.self, from: Data(line.dropFirst(5).utf8)
            ), let result = response.result else { continue }
            return result
        }
        throw URLError(.cannotParseResponse)
    }
}
