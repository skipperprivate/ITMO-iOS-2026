
import Foundation

// Units are normalised: °C, km/h, hPa, km.
nonisolated struct CurrentWeather: Hashable, Codable, Sendable {
    let temperatureCelsius: Double
    let feelsLikeCelsius: Double
    let condition: WeatherCondition
    let isDaytime: Bool
    let windSpeedKmh: Double
    let windGustsKmh: Double
    let windDirectionDegrees: Double
    let humidityPercent: Int
    let pressureHPa: Double
    let uvIndex: Double
    let visibilityKm: Double
    let updatedAt: Date
}
