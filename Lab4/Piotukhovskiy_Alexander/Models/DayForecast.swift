import Foundation

struct DayForecast: Identifiable, Equatable, Sendable {
    var id: Date { date }
    let date: Date
    let minimum: Double
    let maximum: Double
    let weatherCode: Int
}
