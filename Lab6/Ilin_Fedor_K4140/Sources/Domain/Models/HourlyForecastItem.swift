import Foundation

nonisolated struct HourlyForecastItem: Identifiable, Hashable, Codable, Sendable {
    var id: Date { date }
    let date: Date
    let temperatureCelsius: Double
    let condition: WeatherCondition
    let isDaytime: Bool
    let precipitationChancePercent: Int
}
