//
//  DailyWeatherResponse.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 15.10.2026.
//

public struct DailyWeatherResponse: Codable {
    public let time: [String]
    public let temperature2mMax: [Double]
    public let temperature2mMin: [Double]
    public let weatherCode: [Int]
    public let uVIndexMax: [Double]
    public let sunrise: [String]
    public let sunset: [String]
    public let precipitationProbabilityMean: [Int]
    
    enum CodingKeys: String, CodingKey {
            case time
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
            case weatherCode = "weather_code"
            case uVIndexMax = "uv_index_max"
            case sunrise
            case sunset
            case precipitationProbabilityMean = "precipitation_probability_mean"
        }
}
