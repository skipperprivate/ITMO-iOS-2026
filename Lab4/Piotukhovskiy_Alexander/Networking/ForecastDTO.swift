import Foundation

struct ForecastResponseDTO: Decodable {
    let timezone: String
    let utcOffsetSeconds: Int
    let current: CurrentWeatherDTO
    let hourly: HourlyForecastDTO
    let daily: DailyForecastDTO

    enum CodingKeys: String, CodingKey {
        case timezone, current, hourly, daily
        case utcOffsetSeconds = "utc_offset_seconds"
    }
}

struct CurrentWeatherDTO: Decodable {
    let time: String
    let temperature2m: Double?
    let weatherCode: Int?
    let isDay: Int?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }
}

struct HourlyForecastDTO: Decodable {
    let time: [String]
    let temperature2m: [Double?]
    let weatherCode: [Int?]
    let isDay: [Int?]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
        case isDay = "is_day"
    }
}

struct DailyForecastDTO: Decodable {
    let time: [String]
    let temperature2mMin: [Double?]
    let temperature2mMax: [Double?]
    let weatherCode: [Int?]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2mMin = "temperature_2m_min"
        case temperature2mMax = "temperature_2m_max"
        case weatherCode = "weather_code"
    }
}
