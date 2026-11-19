import Foundation

final class TicketmasterAPIClient: Sendable {
    private let httpClient: JSONHTTPClient
    private let apiKey: String
    private let eventsURL = URL(string: "https://app.ticketmaster.com/discovery/v2/events.json")
    private let eventDetailsBaseURL = URL(string: "https://app.ticketmaster.com/discovery/v2/events")

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.httpClient = JSONHTTPClient(session: session)
    }

    func fetchEvents(
        countryCode: String = EventCatalogConfiguration.defaultCountryCode,
        page: Int = 0,
        size: Int = EventCatalogConfiguration.pageSize,
        segmentId: String? = nil,
        keyword: String? = nil,
        city: String? = nil
    ) async throws -> TicketmasterResponseDTO {
        let queryItems = eventQueryItems(
            countryCode: countryCode,
            page: page,
            size: size,
            segmentId: segmentId,
            keyword: keyword,
            city: city
        )
        let request = try makeRequest(url: eventsURL, queryItems: queryItems)
        return try await httpClient.send(request)
    }

    func fetchEventDetails(id: String) async throws -> TicketmasterEventDTO {
        guard !id.isEmpty, let baseURL = eventDetailsBaseURL else {
            throw APIError.invalidURL
        }

        let url = baseURL.appendingPathComponent(id).appendingPathExtension("json")
        let request = try makeRequest(url: url, queryItems: [])
        return try await httpClient.send(request)
    }

    private func makeRequest(url: URL?, queryItems: [URLQueryItem]) throws -> URLRequest {
        guard let url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        components.queryItems = [URLQueryItem(name: "apikey", value: apiKey)] + queryItems

        guard let requestURL = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.timeoutInterval = NetworkConfiguration.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func eventQueryItems(
        countryCode: String,
        page: Int,
        size: Int,
        segmentId: String?,
        keyword: String?,
        city: String?
    ) -> [URLQueryItem] {
        var items = [
            URLQueryItem(name: "countryCode", value: countryCode),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size)),
            URLQueryItem(name: "sort", value: "date,asc")
        ]

        if let segmentId {
            items.append(URLQueryItem(name: "segmentId", value: segmentId))
        }
        if let keyword, !keyword.isEmpty {
            items.append(URLQueryItem(name: "keyword", value: keyword))
        }
        if let city, !city.isEmpty {
            items.append(URLQueryItem(name: "city", value: city))
        }

        return items
    }
}
