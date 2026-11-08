import Foundation

actor OpenMeteoClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchCities(_ query: String) async throws -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return [] }
        guard let url = OpenMeteoRequest.searchURL(query: trimmed) else {
            throw OpenMeteoError.invalidURL
        }
        let response: GeocodingResponseDTO = try await fetch(from: url)
        return response.cities
    }

    func forecast(for city: City) async throws -> WeatherForecast {
        guard let url = OpenMeteoRequest.forecastURL(for: city) else {
            throw OpenMeteoError.invalidURL
        }
        let response: ForecastResponseDTO = try await fetch(from: url)
        do {
            let forecast = try response.toForecast(for: city)
            try Task.checkCancellation()
            guard forecast.hourly.count >= AppConstants.hourlyForecastCount,
                  forecast.daily.count >= AppConstants.dailyForecastCount else {
                throw OpenMeteoError.invalidResponse
            }
            return WeatherForecast(
                cityID: forecast.cityID,
                timezone: forecast.timezone,
                current: forecast.current,
                hourly: Array(forecast.hourly.prefix(AppConstants.hourlyForecastCount)),
                daily: Array(forecast.daily.prefix(AppConstants.dailyForecastCount)),
                loadedAt: forecast.loadedAt
            )
        } catch is ForecastMappingError {
            throw OpenMeteoError.invalidResponse
        }
    }

    private func fetch<Response: Decodable & Sendable>(from url: URL) async throws -> Response {
        try Task.checkCancellation()
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 30)
        do {
            let (data, response) = try await session.data(for: request)
            try Task.checkCancellation()
            guard let http = response as? HTTPURLResponse else {
                throw OpenMeteoError.invalidResponse
            }
            guard (200..<300).contains(http.statusCode) else {
                let apiError = try? JSONDecoder().decode(APIErrorDTO.self, from: data)
                throw OpenMeteoError.http(statusCode: http.statusCode, reason: apiError?.reason)
            }
            do {
                return try JSONDecoder().decode(Response.self, from: data)
            } catch is DecodingError {
                throw OpenMeteoError.invalidResponse
            }
        } catch let error as URLError {
            if error.code == .cancelled || Task.isCancelled {
                throw CancellationError()
            }
            throw OpenMeteoError.network(error.code)
        }
    }
}
