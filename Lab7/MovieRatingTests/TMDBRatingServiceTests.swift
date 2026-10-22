import Foundation
import XCTest
@testable import MovieRating

final class TMDBRatingServiceTests: XCTestCase {

    // MARK: - POST Rating

    func testRateMovieSendsPOSTRequest()
        async throws {

        let client = StubHTTPClient(
            responses: [
                .success(
                    .init(
                        statusCode: 200,
                        body: guestSessionJSON
                    )
                ),
                .success(
                    .init(
                        statusCode: 201,
                        body: ratingResponseJSON
                    )
                )
            ]
        )

        let service = makeService(
            httpClient: client
        )

        try await service.rateMovie(
            movieID: 123,
            value: 8.5
        )

        XCTAssertEqual(
            client.requests.count,
            2
        )

        let guestRequest = client.requests[0]

        XCTAssertEqual(
            guestRequest.httpMethod,
            "GET"
        )

        XCTAssertEqual(
            guestRequest.url?.path,
            "/3/authentication/guest_session/new"
        )

        let ratingRequest = client.requests[1]

        XCTAssertEqual(
            ratingRequest.httpMethod,
            "POST"
        )

        XCTAssertEqual(
            ratingRequest.url?.path,
            "/3/movie/123/rating"
        )

        XCTAssertEqual(
            ratingRequest.value(
                forHTTPHeaderField: "Authorization"
            ),
            "Bearer test-token"
        )

        XCTAssertEqual(
            ratingRequest.value(
                forHTTPHeaderField: "Content-Type"
            ),
            "application/json"
        )

        let requestURL = try XCTUnwrap(
            ratingRequest.url
        )

        let components = try XCTUnwrap(
            URLComponents(
                url: requestURL,
                resolvingAgainstBaseURL: false
            )
        )

        let sessionID = components.queryItems?
            .first {
                $0.name == "guest_session_id"
            }?
            .value

        XCTAssertEqual(
            sessionID,
            "guest-123"
        )

        let body = try XCTUnwrap(
            ratingRequest.httpBody
        )

        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: body
            ) as? [String: Double]
        )

        XCTAssertEqual(
            json["value"],
            8.5
        )
    }

    // MARK: - Guest Session

    func testGuestSessionIsReused()
        async throws {

        let client = StubHTTPClient(
            responses: [
                .success(
                    .init(
                        statusCode: 200,
                        body: guestSessionJSON
                    )
                ),
                .success(
                    .init(
                        statusCode: 201,
                        body: ratingResponseJSON
                    )
                ),
                .success(
                    .init(
                        statusCode: 201,
                        body: ratingResponseJSON
                    )
                )
            ]
        )

        let service = makeService(
            httpClient: client
        )

        try await service.rateMovie(
            movieID: 1,
            value: 7.5
        )

        try await service.rateMovie(
            movieID: 2,
            value: 9.0
        )

        XCTAssertEqual(
            client.requests.count,
            3
        )

        let methods = client.requests.map {
            $0.httpMethod
        }

        XCTAssertEqual(
            methods,
            ["GET", "POST", "POST"]
        )

        let paths = client.requests.compactMap {
            $0.url?.path
        }

        XCTAssertEqual(
            paths,
            [
                "/3/authentication/guest_session/new",
                "/3/movie/1/rating",
                "/3/movie/2/rating"
            ]
        )
    }

    // MARK: - Rating Validation

    func testInvalidRatingIsRejected()
        async {

        let client = StubHTTPClient(
            responses: []
        )

        let service = makeService(
            httpClient: client
        )

        let invalidRatings: [Double] = [
            0.0,
            0.3,
            10.5
        ]

        for value in invalidRatings {

            do {
                try await service.rateMovie(
                    movieID: 1,
                    value: value
                )

                XCTFail(
                    "Оценка \(value) должна быть отклонена"
                )

            } catch let error
                as TMDBRatingService.ServiceError {

                guard case .invalidRating = error else {
                    XCTFail(
                        "Неправильная ошибка: \(error)"
                    )
                    continue
                }

            } catch {
                XCTFail(
                    "Неожиданная ошибка: \(error)"
                )
            }
        }

        XCTAssertTrue(
            client.requests.isEmpty
        )
    }

    // MARK: - Authentication Errors

    func testUnauthorizedGuestSessionThrowsError()
        async {

        let client = StubHTTPClient(
            responses: [
                .success(
                    .init(statusCode: 401)
                )
            ]
        )

        let service = makeService(
            httpClient: client
        )

        do {
            try await service.rateMovie(
                movieID: 1,
                value: 8.0
            )

            XCTFail(
                "Ожидалась ошибка авторизации"
            )

        } catch let error
            as TMDBRatingService.ServiceError {

            guard case .unauthorized = error else {
                XCTFail(
                    "Неправильная ошибка: \(error)"
                )
                return
            }

        } catch {
            XCTFail(
                "Неожиданная ошибка: \(error)"
            )
        }

        XCTAssertEqual(
            client.requests.count,
            1
        )

        let method = client.requests.first?.httpMethod

        XCTAssertEqual(
            method,
            "GET"
        )
    }

    // MARK: - Server Errors

    func testRatingPOSTServerError()
        async {

        let client = StubHTTPClient(
            responses: [
                .success(
                    .init(
                        statusCode: 200,
                        body: guestSessionJSON
                    )
                ),
                .success(
                    .init(
                        statusCode: 500
                    )
                )
            ]
        )

        // ВАЖНО:
        // POST рейтинга выполняет TMDBRatingService,
        // а не TMDBMovieService.

        let service = makeService(
            httpClient: client
        )

        do {
            try await service.rateMovie(
                movieID: 123,
                value: 8.5
            )

            XCTFail(
                "Ожидалась ошибка POST"
            )

        } catch let error
            as TMDBRatingService.ServiceError {

            guard case .serverError(let code) = error else {
                XCTFail(
                    "Получена неправильная ошибка: \(error)"
                )
                return
            }

            XCTAssertEqual(
                code,
                500
            )

        } catch {
            XCTFail(
                "Неожиданная ошибка: \(error)"
            )
        }

        XCTAssertEqual(
            client.requests.count,
            2
        )

        let postRequest = client.requests.last

        let method = postRequest?.httpMethod
        let path = postRequest?.url?.path

        XCTAssertEqual(
            method,
            "POST"
        )

        XCTAssertEqual(
            path,
            "/3/movie/123/rating"
        )
    }

    // MARK: - Test Data

    private var guestSessionJSON: Data {

        Data(
            """
            {
                "success": true,
                "guest_session_id": "guest-123",
                "expires_at": "2030-01-01 00:00:00 UTC"
            }
            """.utf8
        )
    }

    private var ratingResponseJSON: Data {

        Data(
            """
            {
                "status_code": 1,
                "status_message": "Success."
            }
            """.utf8
        )
    }

    // MARK: - Factory

    private func makeService(
        httpClient: HTTPClientProtocol
    ) -> TMDBRatingService {

        TMDBRatingService(
            configuration: TMDBConfiguration(
                accessToken: "test-token"
            ),
            httpClient: httpClient
        )
    }
}
