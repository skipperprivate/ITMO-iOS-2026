//
//  TMDBRatingService.swift
//  MovieRating
//
//  Created by Павел on 15.10.2026.
//


import Foundation

final class TMDBRatingService:
    TMDBRatingServiceProtocol {

    enum ServiceError:
        LocalizedError {

        case invalidURL

        case guestSessionCreationFailed

        case unauthorized

        case forbidden

        case notFound

        case badRequest

        case tooManyRequests

        case serverError(Int)

        case invalidStatusCode(Int)

        case invalidRating

        case encodingFailed

        case decodingFailed

        var errorDescription:
            String? {

            switch self {

            case .invalidURL:
                return
                    "Не удалось сформировать URL."

            case .guestSessionCreationFailed:
                return
                    "Не удалось создать гостевую сессию TMDB."

            case .unauthorized:
                return
                    "Ошибка авторизации TMDB. Проверьте Read Access Token."

            case .forbidden:
                return
                    "TMDB запретил выполнение запроса."

            case .notFound:
                return
                    "Фильм не найден в TMDB."

            case .badRequest:
                return
                    "TMDB отклонил запрос."

            case .tooManyRequests:
                return
                    "Слишком много запросов. Попробуйте позже."

            case .serverError(
                let statusCode
            ):
                return
                    "Ошибка сервера TMDB. HTTP \(statusCode)."

            case .invalidStatusCode(
                let statusCode
            ):
                return
                    "Неожиданный HTTP-код: \(statusCode)."

            case .invalidRating:
                return
                    "Оценка TMDB должна быть от 0.5 до 10 с шагом 0.5."

            case .encodingFailed:
                return
                    "Не удалось сформировать JSON для рейтинга."

            case .decodingFailed:
                return
                    "Не удалось разобрать ответ TMDB."
            }
        }
    }

    private let configuration:
        TMDBConfiguration

    private let httpClient:
        HTTPClientProtocol

    private var guestSessionID:
        String?

    init(
        configuration:
            TMDBConfiguration,
        httpClient:
            HTTPClientProtocol
    ) {
        self.configuration =
            configuration

        self.httpClient =
            httpClient
    }

    func rateMovie(
        movieID: Int,
        value: Double
    ) async throws {

        guard
            isValidRating(
                value
            )
        else {
            throw ServiceError
                .invalidRating
        }

        let guestSessionID =
            try await getGuestSessionID()

        let request =
            try makeRatingRequest(
                movieID:
                    movieID,
                value:
                    value,
                guestSessionID:
                    guestSessionID
            )

        let (
            data,
            response
        ) =
            try await httpClient.data(
                for: request
            )

        try validate(
            response
        )

        do {
            let result =
                try JSONDecoder().decode(
                    TMDBRatingResponseDTO.self,
                    from: data
                )

            guard
                result.statusCode > 0
            else {
                throw ServiceError
                    .decodingFailed
            }

        } catch let error
            as ServiceError {

            throw error

        } catch {

            throw ServiceError
                .decodingFailed
        }
    }

    private func getGuestSessionID()
        async throws -> String {

        if let guestSessionID {
            return guestSessionID
        }

        let request =
            try makeGuestSessionRequest()

        let (
            data,
            response
        ) =
            try await httpClient.data(
                for: request
            )

        try validate(
            response
        )

        do {
            let result =
                try JSONDecoder().decode(
                    TMDBGuestSessionDTO.self,
                    from: data
                )

            guard result.success
            else {
                throw ServiceError
                    .guestSessionCreationFailed
            }

            guestSessionID =
                result.guestSessionID

            return result
                .guestSessionID

        } catch let error
            as ServiceError {

            throw error

        } catch {

            throw ServiceError
                .decodingFailed
        }
    }

    private func makeGuestSessionRequest()
        throws -> URLRequest {

        let url =
            configuration
                .apiBaseURL
                .appendingPathComponent(
                    "authentication/guest_session/new"
                )

        var request =
            URLRequest(
                url: url
            )

        request.httpMethod =
            "GET"

        request.timeoutInterval =
            15

        request.setValue(
            "Bearer \(configuration.accessToken)",
            forHTTPHeaderField:
                "Authorization"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        return request
    }

    private func makeRatingRequest(
        movieID: Int,
        value: Double,
        guestSessionID: String
    ) throws -> URLRequest {

        let endpoint =
            configuration
                .apiBaseURL
                .appendingPathComponent(
                    "movie/\(movieID)/rating"
                )

        guard
            var components =
                URLComponents(
                    url: endpoint,
                    resolvingAgainstBaseURL:
                        false
                )
        else {
            throw ServiceError
                .invalidURL
        }

        components.queryItems = [
            URLQueryItem(
                name:
                    "guest_session_id",
                value:
                    guestSessionID
            )
        ]

        guard
            let url =
                components.url
        else {
            throw ServiceError
                .invalidURL
        }

        var request =
            URLRequest(
                url: url
            )

        request.httpMethod =
            "POST"

        request.timeoutInterval =
            15

        request.setValue(
            "Bearer \(configuration.accessToken)",
            forHTTPHeaderField:
                "Authorization"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        let body =
            TMDBRatingRequestDTO(
                value: value
            )

        do {
            request.httpBody =
                try JSONEncoder()
                    .encode(
                        body
                    )

        } catch {
            throw ServiceError
                .encodingFailed
        }

        return request
    }

    private func validate(
        _ response:
            HTTPURLResponse
    ) throws {

        switch response.statusCode {

        case 200...299:
            return

        case 400:
            throw ServiceError
                .badRequest

        case 401:
            throw ServiceError
                .unauthorized

        case 403:
            throw ServiceError
                .forbidden

        case 404:
            throw ServiceError
                .notFound

        case 429:
            throw ServiceError
                .tooManyRequests

        case 500...599:
            throw ServiceError
                .serverError(
                    response.statusCode
                )

        default:
            throw ServiceError
                .invalidStatusCode(
                    response.statusCode
                )
        }
    }

    private func isValidRating(
        _ value: Double
    ) -> Bool {

        guard
            (0.5...10).contains(
                value
            )
        else {
            return false
        }

        let doubled =
            value * 2

        return doubled
            .rounded() ==
            doubled
    }
}
