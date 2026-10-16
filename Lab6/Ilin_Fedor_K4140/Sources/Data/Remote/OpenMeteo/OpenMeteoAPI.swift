import Foundation

nonisolated enum OpenMeteoAPI {
    static let forecastHost = "api.open-meteo.com"
    static let geocodingHost = "geocoding-api.open-meteo.com"
    static let forecastDays = 10
    static let searchResultLimit = 20
    static let language = "ru"

    static func forecast(latitude: Double, longitude: Double, timeZoneIdentifier: String) -> Endpoint<OpenMeteoForecastDTO> {
        Endpoint(
            host: forecastHost,
            path: "/v1/forecast",
            queryItems: [
                URLQueryItem(name: "latitude", value: coordinate(latitude)),
                URLQueryItem(name: "longitude", value: coordinate(longitude)),
                URLQueryItem(name: "current", value: fields(OpenMeteoForecastDTO.Current.CodingKeys.self)),
                URLQueryItem(name: "hourly", value: fields(OpenMeteoForecastDTO.Hourly.CodingKeys.self)),
                URLQueryItem(name: "daily", value: fields(OpenMeteoForecastDTO.Daily.CodingKeys.self)),
                URLQueryItem(name: "timezone", value: timeZoneIdentifier.isEmpty ? "auto" : timeZoneIdentifier),
                URLQueryItem(name: "forecast_days", value: String(forecastDays)),
                URLQueryItem(name: "timeformat", value: "unixtime"),
                URLQueryItem(name: "temperature_unit", value: "celsius"),
                URLQueryItem(name: "wind_speed_unit", value: "kmh"),
                URLQueryItem(name: "precipitation_unit", value: "mm")
            ]
        )
    }

    static func search(name: String, count: Int = searchResultLimit) -> Endpoint<OpenMeteoGeocodingDTO> {
        Endpoint(
            host: geocodingHost,
            path: "/v1/search",
            queryItems: [
                URLQueryItem(name: "name", value: name),
                URLQueryItem(name: "count", value: String(min(max(count, 1), 100))),
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "format", value: "json")
            ]
        )
    }

    static func errorReason(from data: Data) -> String? {
        try? JSONDecoder().decode(OpenMeteoErrorDTO.self, from: data).reason
    }

    private static func fields<Key: CodingKey & CaseIterable>(_ keys: Key.Type) -> String {
        keys.allCases.map(\.stringValue).filter { $0 != "time" }.joined(separator: ",")
    }

    private static func coordinate(_ value: Double) -> String {
        String(format: "%.4f", locale: Locale(identifier: "en_US_POSIX"), value)
    }
}

nonisolated extension NetworkClient {
    static let openMeteo = NetworkClient(
        maxConcurrentRequests: 3,
        errorMessageParser: OpenMeteoAPI.errorReason(from:)
    )
}
