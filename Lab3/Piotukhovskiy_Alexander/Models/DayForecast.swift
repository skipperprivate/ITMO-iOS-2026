import Foundation

struct DayForecast: Identifiable {
    let id = UUID()
    let title: String
    let minimum: Int
    let maximum: Int
    let condition: String
}
