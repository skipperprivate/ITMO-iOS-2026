//
//  TestMocks.swift
//  WeatherlyTests
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation
@testable import Weatherly

// Intercepts every request of a session built with `URLProtocolStub.makeSession()`.
final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    enum Reply {
        case response(statusCode: Int, body: Data, headers: [String: String] = [:])
        case failure(URLError.Code)
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var replies: [Reply] = []
    nonisolated(unsafe) private static var recorded: [URLRequest] = []

    // Replies are consumed in order; the last one repeats for any extra request.
    static func stub(_ replies: Reply...) {
        lock.withLock {
            self.replies = replies
            recorded = []
        }
    }

    static var requests: [URLRequest] {
        lock.withLock { recorded }
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let reply: Reply? = Self.lock.withLock {
            Self.recorded.append(request)
            return Self.replies.count > 1 ? Self.replies.removeFirst() : Self.replies.first
        }
        switch reply {
        case .response(let statusCode, let body, let headers):
            let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headers)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: body)
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let code):
            client?.urlProtocol(self, didFailWithError: URLError(code))
        case nil:
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
        }
    }

    override func stopLoading() {}
}

// Answers endpoints by URL without touching URLSession; decodes with the real DTOs.
final class StubNetworkClient: NetworkClientProtocol, @unchecked Sendable {
    typealias Handler = @Sendable (URLRequest) throws -> Data

    private let lock = NSLock()
    private let handler: Handler
    private var recorded: [URLRequest] = []

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    var requests: [URLRequest] {
        lock.withLock { recorded }
    }

    func send<Response>(_ endpoint: Endpoint<Response>) async throws -> Response {
        let request = try endpoint.makeRequest()
        lock.withLock { recorded.append(request) }
        return try JSONDecoder().decode(Response.self, from: try handler(request))
    }
}

extension URLRequest {
    func queryValue(_ name: String) -> String? {
        url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
            .queryItems?.first { $0.name == name }?.value
    }
}

enum TestCities {
    static let moscow = City(id: "524901", name: "Москва", region: "", country: "Россия", latitude: 55.752, longitude: 37.6178, timeZoneIdentifier: "Europe/Moscow")
    static let kazan = City(id: "551487", name: "Казань", region: "Татарстан", country: "Россия", latitude: 55.7887, longitude: 49.1221, timeZoneIdentifier: "Europe/Moscow")
    static let sochi = City(id: "491422", name: "Сочи", region: "Краснодарский край", country: "Россия", latitude: 43.6028, longitude: 39.7342, timeZoneIdentifier: "Europe/Moscow")
}

// MARK: - Repository doubles for ViewModel and decorator tests

// Answers per city from a closure, counts calls and can hold every answer until `release()`.
final class StubWeatherRepository: WeatherRepositoryProtocol, @unchecked Sendable {
    typealias Handler = @Sendable (City) throws -> CityWeatherSnapshot

    private let lock = NSLock()
    private var handler: Handler
    private var calls: [City] = []
    private var isHeld = false
    private var waiting: [CheckedContinuation<Void, Never>] = []

    init(handler: @escaping Handler = { MockData.snapshot(for: $0) }) {
        self.handler = handler
    }

    var callCount: Int { lock.withLock { calls.count } }
    var requestedCities: [City] { lock.withLock { calls } }

    func respond(with handler: @escaping Handler) {
        lock.withLock { self.handler = handler }
    }

    func hold() {
        lock.withLock { isHeld = true }
    }

    func release() {
        let continuations = lock.withLock {
            isHeld = false
            defer { waiting.removeAll() }
            return waiting
        }
        continuations.forEach { $0.resume() }
    }

    func snapshot(for city: City) async throws -> CityWeatherSnapshot {
        let mustWait = lock.withLock {
            calls.append(city)
            return isHeld
        }
        if mustWait {
            await withCheckedContinuation { continuation in
                let stillHeld = lock.withLock {
                    if isHeld { waiting.append(continuation) }
                    return isHeld
                }
                if !stillHeld { continuation.resume() }
            }
        }
        try Task.checkCancellation()
        let handler = lock.withLock { self.handler }
        return try handler(city)
    }
}

final class StubGeocodingRepository: GeocodingRepositoryProtocol, @unchecked Sendable {
    let minimumQueryLength = 2
    private let lock = NSLock()
    private var result: Result<[City], RepositoryError>
    private var queries: [String] = []

    init(result: Result<[City], RepositoryError> = .success([])) {
        self.result = result
    }

    var receivedQueries: [String] { lock.withLock { queries } }

    func respond(with result: Result<[City], RepositoryError>) {
        lock.withLock { self.result = result }
    }

    func searchCities(matching query: String) async throws -> [City] {
        let result = lock.withLock {
            queries.append(query)
            return self.result
        }
        return try result.get()
    }
}

// Polls a condition on the main actor; debounce and unstructured tasks finish on their own schedule.
@MainActor
func waitUntil(timeout: TimeInterval = 2, _ condition: () -> Bool) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while !condition() {
        if Date() > deadline { return false }
        try? await Task.sleep(nanoseconds: 10_000_000)
    }
    return true
}
