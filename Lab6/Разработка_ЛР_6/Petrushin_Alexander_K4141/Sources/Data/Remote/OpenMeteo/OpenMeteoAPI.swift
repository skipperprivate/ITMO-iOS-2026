import Foundation

// https://open-meteo.com/en/docs and https://open-meteo.com/en/docs/geocoding-api
nonisolated enum OpenMeteoAPI {
    static let forecastHost = "api.open-meteo.com"
    static let geocodingHost = "geocoding-api.open-meteo.com"
    static let forecastDays = 10
    static let searchResultLimit = 20
    static let language = "ru"

    // Units are pinned explicitly so the domain's °C / km/h / hPa / mm never depend on API defaults.
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
                // Days must start at midnight in the city's zone, the same one City.calendar uses.
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

    // The requested variables are exactly the DTO's keys, so the two can't drift apart.
    private static func fields<Key: CodingKey & CaseIterable>(_ keys: Key.Type) -> String {
        keys.allCases.map(\.stringValue).filter { $0 != "time" }.joined(separator: ",")
    }

    // Locale-independent: "55.7558", never "55,7558" or "5.5e1".
    private static func coordinate(_ value: Double) -> String {
        String(format: "%.4f", locale: Locale(identifier: "en_US_POSIX"), value)
    }
}

nonisolated extension NetworkClient {
    // The server runs one request per IP at a time, queues the rest and answers the 6th in flight
    // with 429 "Too many concurrent requests"; 3 leaves headroom for other devices behind the same NAT.
    static let openMeteo = NetworkClient(
        maxConcurrentRequests: 3,
        errorMessageParser: OpenMeteoAPI.errorReason(from:)
    )
}
