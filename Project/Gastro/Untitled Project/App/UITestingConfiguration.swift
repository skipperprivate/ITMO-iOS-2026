#if DEBUG
import Foundation

/// Enabled only by the UI test runner. Release builds cannot activate this mode.
enum UITestingConfiguration {
    static var isEnabled: Bool { ProcessInfo.processInfo.arguments.contains("--ui-testing") }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [UITestingURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    static func makeProfileDefaults() -> UserDefaults {
        let suite = "dev.gastro.ui-tests.profile"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }
}

/// Exercises the production client and services without depending on a remote server.
nonisolated private final class UITestingURLProtocol: URLProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var pendingResponse: DispatchWorkItem?
    private var stopped = false

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let work = DispatchWorkItem { [weak self] in self?.respond() }
        lock.lock()
        pendingResponse = work
        lock.unlock()
        let delay = request.url?.path == "/recipes/add" ? 5.0 : 0.0
        DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: work)
    }

    override func stopLoading() {
        lock.lock()
        stopped = true
        pendingResponse?.cancel()
        pendingResponse = nil
        lock.unlock()
    }

    private func respond() {
        lock.lock()
        defer { lock.unlock() }
        guard !stopped, let url = request.url else { return }
        let status: Int
        let body: String
        switch (request.httpMethod, url.path) {
            case ("GET", "/recipes"):
                status = 200
                body = #"{"recipes":[],"total":0,"skip":0,"limit":0}"#
            case ("POST", "/recipes/add"):
                status = 201
                body = #"{"id":51,"name":"UI test recipe"}"#
            case ("POST", "/http/500"):
                status = 500
                body = #"{"message":"Internal Server Error"}"#
            default:
                // Fail unexpected requests locally; never fall through to the real network.
                status = 404
                body = #"{"message":"No UI test fixture for this request"}"#
        }
        guard
            let response = HTTPURLResponse(
                url: url,
                statusCode: status,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )
        else { return }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
}
#endif
