import Foundation

final class TMDBMovieService:
    MovieServiceProtocol {

    enum ServiceError:
        LocalizedError {

        case invalidURL

        case unauthorized

        case forbidden

        case notFound

        case badRequest

        case tooManyRequests

        case serverError(Int)

        case invalidStatusCode(Int)

        case noInternet

        case timedOut

        case serverUnavailable

        case networkError(Error)

        case decodingFailed

        var errorDescription:
            String? {

            switch self {

            case .invalidURL:
                return
                    "Не удалось сформировать URL запроса."

            case .unauthorized:
                return
                    "Ошибка авторизации TMDB. Проверьте API Read Access Token."

            case .forbidden:
                return
                    "TMDB запретил выполнение запроса."

            case .notFound:
                return
                    "Запрашиваемый ресурс не найден."

            case .badRequest:
                return
                    "Некорректный запрос к TMDB."

            case .tooManyRequests:
                return
                    "Слишком много запросов к TMDB. Попробуйте позже."

            case .serverError(
                let statusCode
            ):
                return
                    "Ошибка сервера TMDB. HTTP \(statusCode)."

            case .invalidStatusCode(
                let statusCode
            ):
                return
                    "TMDB вернул неожиданный HTTP-код: \(statusCode)."

            case .noInternet:
                return
                    "Нет подключения к интернету."

            case .timedOut:
                return
                    "Сервер не ответил вовремя. Попробуйте ещё раз."

            case .serverUnavailable:
                return
                    "Не удалось подключиться к серверу TMDB."

            case .networkError(
                let error
            ):
                return
                    "Ошибка сети: \(error.localizedDescription)"

            case .decodingFailed:
                return
                    "Не удалось разобрать данные, полученные от TMDB."
            }
        }
    }

    private let configuration:
        TMDBConfiguration

    private let httpClient:
        HTTPClientProtocol

    private let mapper:
        TMDBMovieMapper

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

        self.mapper =
            TMDBMovieMapper(
                imageBaseURL:
                    configuration
                        .imageBaseURL
            )
    }

    func getMovies() async throws
        -> [Movie] {

        let request =
            try makePopularMoviesRequest()

        let data: Data
        let response: HTTPURLResponse

        do {
            (data, response) =
                try await httpClient.data(
                    for: request
                )

        } catch let error as URLError {

            throw mapNetworkError(
                error
            )

        } catch {

            throw ServiceError
                .networkError(
                    error
                )
        }

        try validate(
            response
        )

        do {
            let decoded =
                try JSONDecoder().decode(
                    TMDBMovieListResponse.self,
                    from: data
                )

            return decoded.results.map {
                mapper.map(
                    $0
                )
            }

        } catch {
            throw ServiceError
                .decodingFailed
        }
    }

    private func makePopularMoviesRequest()
        throws -> URLRequest {

        let endpoint =
            configuration
                .apiBaseURL
                .appendingPathComponent(
                    "movie/popular"
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
                name: "language",
                value: "ru-RU"
            ),

            URLQueryItem(
                name: "page",
                value: "1"
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

    private func validate(
        _ response: HTTPURLResponse
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

    private func mapNetworkError(
        _ error: URLError
    ) -> ServiceError {

        switch error.code {

        case .notConnectedToInternet:
            return .noInternet

        case .timedOut:
            return .timedOut

        case .cannotFindHost,
             .cannotConnectToHost,
             .dnsLookupFailed:
            return .serverUnavailable

        default:
            return .networkError(
                error
            )
        }
    }
}
