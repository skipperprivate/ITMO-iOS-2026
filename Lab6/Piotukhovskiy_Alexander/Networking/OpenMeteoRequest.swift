import Foundation

enum OpenMeteoRequest {
    static func forecastURL(for city: City) -> URL? {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(city.latitude)),
            URLQueryItem(name: "longitude", value: String(city.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code,is_day"),
            URLQueryItem(name: "hourly", value: "temperature_2m,weather_code,is_day"),
            URLQueryItem(name: "daily", value: "temperature_2m_min,temperature_2m_max,weather_code"),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "timeformat", value: "iso8601"),
            URLQueryItem(name: "forecast_hours", value: String(AppConstants.hourlyForecastCount)),
            URLQueryItem(name: "forecast_days", value: String(AppConstants.dailyForecastCount))
        ]
        return components?.url
    }

    static func searchURL(query: String) -> URL? {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "language", value: "ru"),
            URLQueryItem(name: "format", value: "json")
        ]
        return components?.url
    }
}
