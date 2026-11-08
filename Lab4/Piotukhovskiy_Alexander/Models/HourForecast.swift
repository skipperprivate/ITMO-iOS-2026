import Foundation

struct HourForecast: Identifiable, Equatable, Sendable {
    var id: Date { date }
    let date: Date
    let temperature: Double
    let weatherCode: Int
    let isDay: Bool
}
