import Foundation

struct HourForecast: Identifiable {
    let id = UUID()
    let title: String
    let temperature: Int
    let condition: String
}
