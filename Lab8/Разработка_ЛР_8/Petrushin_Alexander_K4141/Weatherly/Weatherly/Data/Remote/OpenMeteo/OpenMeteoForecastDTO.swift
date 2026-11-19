import Foundation

// Mirrors /v1/forecast with timeformat=unixtime. Series elements are optional:
// Open-Meteo puts null where a model has no data for that hour or day.
nonisolated struct OpenMeteoForecastDTO: Decodable, Sendable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let utcOffsetSeconds: Int
    let current: Current
    let hourly: Hourly
    let daily: Daily

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, timezone, current, hourly, daily
        case utcOffsetSeconds = "utc_offset_seconds"
    }

    nonisolated struct Current: Decodable, Sendable {
        let time: TimeInterval
        let temperature: Double?
        let apparentTemperature: Double?
        let weatherCode: Int?
        let isDay: Int?
        let windSpeed: Double?
        let windGusts: Double?
        let windDirection: Double?
        let relativeHumidity: Double?
        let pressureMSL: Double?
        let uvIndex: Double?
        let visibility: Double?

        enum CodingKeys: String, CodingKey, CaseIterable {
            case time
            case temperature = "temperature_2m"
            case apparentTemperature = "apparent_temperature"
            case weatherCode = "weather_code"
            case isDay = "is_day"
            case windSpeed = "wind_speed_10m"
            case windGusts = "wind_gusts_10m"
            case windDirection = "wind_direction_10m"
            case relativeHumidity = "relative_humidity_2m"
            case pressureMSL = "pressure_msl"
            case uvIndex = "uv_index"
            case visibility
        }
    }

    nonisolated struct Hourly: Decodable, Sendable {
        let time: [TimeInterval]
        let temperature: [Double?]
        let weatherCode: [Int?]
        let isDay: [Int?]
        let precipitationProbability: [Double?]

        enum CodingKeys: String, CodingKey, CaseIterable {
            case time
            case temperature = "temperature_2m"
            case weatherCode = "weather_code"
            case isDay = "is_day"
            case precipitationProbability = "precipitation_probability"
        }
    }

    nonisolated struct Daily: Decodable, Sendable {
        let time: [TimeInterval]
        let weatherCode: [Int?]
        let temperatureMax: [Double?]
        let temperatureMin: [Double?]
        let precipitationProbabilityMax: [Double?]
        let precipitationSum: [Double?]
        let windSpeedMax: [Double?]
        let uvIndexMax: [Double?]
        let sunrise: [TimeInterval?]
        let sunset: [TimeInterval?]

        enum CodingKeys: String, CodingKey, CaseIterable {
            case time
            case weatherCode = "weather_code"
            case temperatureMax = "temperature_2m_max"
            case temperatureMin = "temperature_2m_min"
            case precipitationProbabilityMax = "precipitation_probability_max"
            case precipitationSum = "precipitation_sum"
            case windSpeedMax = "wind_speed_10m_max"
            case uvIndexMax = "uv_index_max"
            case sunrise, sunset
        }
    }
}
