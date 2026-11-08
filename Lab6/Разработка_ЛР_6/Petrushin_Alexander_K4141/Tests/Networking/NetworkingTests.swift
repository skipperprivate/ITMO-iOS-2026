//
//  NetworkingTests.swift
//  WeatherlyTests
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import XCTest
@testable import Weatherly

final class EndpointTests: XCTestCase {
    func testForecastEndpointPinsUnitsZoneAndFields() throws {
        let request = try OpenMeteoAPI.forecast(latitude: 55.7558, longitude: 37.6173, timeZoneIdentifier: "Europe/Moscow").makeRequest()

        XCTAssertEqual(request.url?.host, "api.open-meteo.com")
        XCTAssertEqual(request.url?.path, "/v1/forecast")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.queryValue("latitude"), "55.7558")
        XCTAssertEqual(request.queryValue("longitude"), "37.6173")
        XCTAssertEqual(request.queryValue("timezone"), "Europe/Moscow")
        XCTAssertEqual(request.queryValue("forecast_days"), "10")
        XCTAssertEqual(request.queryValue("timeformat"), "unixtime")
        XCTAssertEqual(request.queryValue("temperature_unit"), "celsius")
        XCTAssertEqual(request.queryValue("wind_speed_unit"), "kmh")
        XCTAssertEqual(request.queryValue("precipitation_unit"), "mm")

        let current = try XCTUnwrap(request.queryValue("current")).split(separator: ",")
        XCTAssertTrue(current.contains("temperature_2m"))
        XCTAssertTrue(current.contains("visibility"))
        XCTAssertFalse(current.contains("time"))
        XCTAssertEqual(request.queryValue("hourly"), "temperature_2m,weather_code,is_day,precipitation_probability")
        XCTAssertTrue(try XCTUnwrap(request.queryValue("daily")).contains("sunrise"))
    }

    func testForecastEndpointFallsBackToAutoZone() throws {
        let request = try OpenMeteoAPI.forecast(latitude: 0, longitude: 0, timeZoneIdentifier: "").makeRequest()
        XCTAssertEqual(request.queryValue("timezone"), "auto")
    }

    func testCoordinatesNeverUseExponentOrComma() throws {
        let request = try OpenMeteoAPI.forecast(latitude: 0.00001, longitude: -122.4194155, timeZoneIdentifier: "UTC").makeRequest()
        XCTAssertEqual(request.queryValue("latitude"), "0.0000")
        XCTAssertEqual(request.queryValue("longitude"), "-122.4194")
    }

    func testSearchEndpointEncodesCyrillicAndPlus() throws {
        let request = try OpenMeteoAPI.search(name: "Санкт+Петербург").makeRequest()
        let url = try XCTUnwrap(request.url?.absoluteString)

        XCTAssertTrue(url.hasPrefix("https://geocoding-api.open-meteo.com/v1/search?"))
        XCTAssertTrue(url.contains("%2B"), "'+' must be escaped, otherwise the server reads it as a space")
        XCTAssertEqual(request.queryValue("name"), "Санкт+Петербург")
        XCTAssertEqual(request.queryValue("language"), "ru")
        XCTAssertEqual(request.queryValue("count"), "20")
    }

    func testSearchEndpointClampsCountToAPILimits() throws {
        XCTAssertEqual(try OpenMeteoAPI.search(name: "a", count: 500).makeRequest().queryValue("count"), "100")
        XCTAssertEqual(try OpenMeteoAPI.search(name: "a", count: 0).makeRequest().queryValue("count"), "1")
    }

    func testErrorReasonIsExtractedFromBody() {
        XCTAssertEqual(OpenMeteoAPI.errorReason(from: Data(Fixtures.errorJSON.utf8)), "Latitude must be in range of -90 to 90°. Given: 200.0.")
        XCTAssertEqual(OpenMeteoAPI.errorReason(from: Data(#"{"error":"Too many requests"}"#.utf8)), "Too many requests")
        XCTAssertNil(OpenMeteoAPI.errorReason(from: Data(#"{"error":true,"reason":"  "}"#.utf8)))
        XCTAssertNil(OpenMeteoAPI.errorReason(from: Data("<html>502</html>".utf8)))
    }
}

final class RetryPolicyTests: XCTestCase {
    private let policy = RetryPolicy(maxAttempts: 4, baseDelay: 1, maxDelay: 3, jitter: 1...1)

    func testBackoffGrowsExponentiallyUpToCap() {
        XCTAssertEqual(policy.delay(afterAttempt: 1, failedWith: .timedOut), 1)
        XCTAssertEqual(policy.delay(afterAttempt: 2, failedWith: .timedOut), 2)
        XCTAssertEqual(policy.delay(afterAttempt: 3, failedWith: .timedOut), 3)
        XCTAssertNil(policy.delay(afterAttempt: 4, failedWith: .timedOut))
    }

    func testOnlyTransientErrorsAreRetried() {
        XCTAssertNotNil(policy.delay(afterAttempt: 1, failedWith: .httpStatus(code: 503, message: nil)))
        XCTAssertNotNil(policy.delay(afterAttempt: 1, failedWith: .cannotReachServer))
        XCTAssertNil(policy.delay(afterAttempt: 1, failedWith: .httpStatus(code: 400, message: nil)))
        XCTAssertNil(policy.delay(afterAttempt: 1, failedWith: .notConnected))
        XCTAssertNil(policy.delay(afterAttempt: 1, failedWith: .decodingFailed("x")))
    }

    func testRetryAfterIsHonouredButNotBeyondMaxDelay() {
        XCTAssertEqual(policy.delay(afterAttempt: 1, failedWith: .rateLimited(retryAfter: 2)), 2)
        XCTAssertNil(policy.delay(afterAttempt: 1, failedWith: .rateLimited(retryAfter: 60)))
        XCTAssertEqual(policy.delay(afterAttempt: 1, failedWith: .rateLimited(retryAfter: nil)), 1)
    }
}

final class NetworkClientTests: XCTestCase {
    private var client: NetworkClient!
    private let endpoint = OpenMeteoAPI.forecast(latitude: 55.75, longitude: 37.62, timeZoneIdentifier: "Europe/Moscow")

    override func setUp() {
        super.setUp()
        client = NetworkClient(
            session: URLProtocolStub.makeSession(),
            retryPolicy: RetryPolicy(maxAttempts: 3, baseDelay: 0, maxDelay: 1),
            errorMessageParser: OpenMeteoAPI.errorReason(from:)
        )
    }

    func testDecodesSuccessfulResponse() async throws {
        URLProtocolStub.stub(.response(statusCode: 200, body: Fixtures.forecastData))

        let dto = try await client.send(endpoint)

        XCTAssertEqual(dto.timezone, "Europe/Moscow")
        XCTAssertEqual(dto.hourly.time.count, 48)
        XCTAssertEqual(URLProtocolStub.requests.count, 1)
    }

    func testClientErrorCarriesServerReasonAndIsNotRetried() async {
        URLProtocolStub.stub(.response(statusCode: 400, body: Data(Fixtures.errorJSON.utf8)))

        await assertThrows(.httpStatus(code: 400, message: "Latitude must be in range of -90 to 90°. Given: 200.0."))
        XCTAssertEqual(URLProtocolStub.requests.count, 1)
    }

    func testServerErrorIsRetriedUntilSuccess() async throws {
        URLProtocolStub.stub(
            .response(statusCode: 503, body: Data()),
            .failure(.networkConnectionLost),
            .response(statusCode: 200, body: Fixtures.forecastData)
        )

        _ = try await client.send(endpoint)
        XCTAssertEqual(URLProtocolStub.requests.count, 3)
    }

    func testGivesUpAfterMaxAttempts() async {
        URLProtocolStub.stub(.response(statusCode: 502, body: Data("<html>Bad Gateway</html>".utf8)))

        await assertThrows(.httpStatus(code: 502, message: nil))
        XCTAssertEqual(URLProtocolStub.requests.count, 3)
    }

    func testOfflineFailsFastWithoutRetry() async {
        URLProtocolStub.stub(.failure(.notConnectedToInternet))

        await assertThrows(.notConnected)
        XCTAssertEqual(URLProtocolStub.requests.count, 1)
    }

    func testTimeoutIsRetried() async {
        URLProtocolStub.stub(.failure(.timedOut))

        await assertThrows(.timedOut)
        XCTAssertEqual(URLProtocolStub.requests.count, 3)
    }

    func testRateLimitRespectsRetryAfter() async throws {
        URLProtocolStub.stub(
            .response(statusCode: 429, body: Data(), headers: ["Retry-After": "0"]),
            .response(statusCode: 200, body: Fixtures.forecastData)
        )

        _ = try await client.send(endpoint)
        XCTAssertEqual(URLProtocolStub.requests.count, 2)
    }

    func testRateLimitWithLongRetryAfterFailsImmediately() async {
        URLProtocolStub.stub(.response(statusCode: 429, body: Data(), headers: ["Retry-After": "120"]))

        await assertThrows(.rateLimited(retryAfter: 120))
        XCTAssertEqual(URLProtocolStub.requests.count, 1)
    }

    func testMalformedJSONIsDecodingFailureWithoutRetry() async {
        URLProtocolStub.stub(.response(statusCode: 200, body: Data(#"{"latitude": "oops"}"#.utf8)))

        do {
            _ = try await client.send(endpoint)
            XCTFail("Expected decoding failure")
        } catch NetworkError.decodingFailed(let details) {
            XCTAssertTrue(details.contains("latitude"), details)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        XCTAssertEqual(URLProtocolStub.requests.count, 1)
    }

    func testEmptyBodyIsInvalidResponse() async {
        URLProtocolStub.stub(.response(statusCode: 200, body: Data()))

        await assertThrows(.invalidResponse)
    }

    func testCancellationSurfacesAsCancellationError() async {
        URLProtocolStub.stub(.failure(.timedOut))
        let client = NetworkClient(
            session: URLProtocolStub.makeSession(),
            retryPolicy: RetryPolicy(maxAttempts: 5, baseDelay: 10, maxDelay: 10)
        )
        let endpoint = endpoint
        let task = Task { try await client.send(endpoint) }
        try? await Task.sleep(nanoseconds: 100_000_000)
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError, "Got \(error)")
        }
    }

    private func assertThrows(_ expected: NetworkError, file: StaticString = #filePath, line: UInt = #line) async {
        do {
            _ = try await client.send(endpoint)
            XCTFail("Expected \(expected)", file: file, line: line)
        } catch let error as NetworkError {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: file, line: line)
        }
    }
}

final class NetworkErrorTests: XCTestCase {
    func testURLErrorsAreClassified() {
        XCTAssertEqual(NetworkError(URLError(.notConnectedToInternet)), .notConnected)
        XCTAssertEqual(NetworkError(URLError(.timedOut)), .timedOut)
        XCTAssertEqual(NetworkError(URLError(.cannotFindHost)), .cannotReachServer)
        XCTAssertEqual(NetworkError(URLError(.serverCertificateUntrusted)), .secureConnectionFailed)
        XCTAssertEqual(NetworkError(URLError(.badServerResponse)), .invalidResponse)
        XCTAssertEqual(NetworkError(URLError(.userAuthenticationRequired)), .transport(.userAuthenticationRequired))
    }

    func testTranslationToRepositoryError() {
        XCTAssertEqual(RepositoryError(.notConnected), .offline)
        XCTAssertEqual(RepositoryError(.timedOut), .timedOut)
        XCTAssertEqual(RepositoryError(.rateLimited(retryAfter: nil)), .rateLimited)
        XCTAssertEqual(RepositoryError(.httpStatus(code: 503, message: nil)), .serviceUnavailable)
        XCTAssertEqual(RepositoryError(.httpStatus(code: 400, message: "bad")), .requestRejected)
        XCTAssertEqual(RepositoryError(.decodingFailed("x")), .invalidData)
    }
}
