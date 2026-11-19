import Foundation

enum WeatherViewState: Equatable {
    case idle
    case loading
    case loaded(Weather)
    case notFound(city: String)
    case error(message: String)
}
