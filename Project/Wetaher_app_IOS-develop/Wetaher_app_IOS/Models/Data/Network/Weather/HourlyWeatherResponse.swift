//
//  HourlyWeatherResponse.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 15.10.2026.
//

public struct HourlyWeatherResponse: Codable {
    public let time: [String]
    public let temperature2m: [Double]
    public let weatherCode: [Int]
    public let isDay: [Int]
    public let precipitationProbability: [Int]

    enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case weatherCode = "weather_code"
            case isDay = "is_day"
            case precipitationProbability = "precipitation_probability"
    }
}
