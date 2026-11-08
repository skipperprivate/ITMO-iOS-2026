import Foundation

struct CurrentWeather: Equatable, Sendable {
    let date: Date
    let temperature: Double
    let weatherCode: Int
    let isDay: Bool
}
