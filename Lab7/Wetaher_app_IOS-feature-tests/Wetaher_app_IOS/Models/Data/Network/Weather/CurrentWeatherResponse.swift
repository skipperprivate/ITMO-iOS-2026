//
//  CurrentWeatherResponse.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 15.10.2026.
//

public struct CurrentWeatherResponse: Codable {
    public let time: String
    public let temperature2m: Double
    public let apparentTemperature: Double
    public let weatherCode: Int
    public let isDay: Int
    public let windSpeed10m: Double
    public let windDirection10m: Int
    public let windGusts10m: Double
    public let relativeHumidity2m: Int
    public let dewPoint2m: Double
    public let pressureMsl: Double
    public let visibility: Double

    enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case apparentTemperature = "apparent_temperature"
            case weatherCode = "weather_code"
            case isDay = "is_day"
            case windSpeed10m = "wind_speed_10m"
            case windDirection10m = "wind_direction_10m"
            case windGusts10m = "wind_gusts_10m"
            case relativeHumidity2m = "relative_humidity_2m"
            case dewPoint2m = "dew_point_2m"
            case pressureMsl = "pressure_msl"
            case visibility
        }
}
