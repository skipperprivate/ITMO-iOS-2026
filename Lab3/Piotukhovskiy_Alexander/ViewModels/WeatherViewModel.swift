import Combine

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published private(set) var city = "Moscow"
    @Published private(set) var currentTemperature = 0
    @Published private(set) var currentCondition = "Sun"
    @Published private(set) var hourly: [HourForecast] = []
    @Published private(set) var daily: [DayForecast] = []
    @Published var useFahrenheit = false

    private let service = MockWeatherService()

    init() {
        refresh()
    }

    func selectCity(_ newCity: String) {
        city = newCity
        refresh()
    }

    func refresh() {
        let forecast = service.forecast(for: city)
        city = forecast.city
        currentTemperature = forecast.currentTemperature
        currentCondition = forecast.currentCondition
        hourly = forecast.hourly
        daily = forecast.daily
    }

    func temperatureText(_ celsius: Int) -> String {
        let value = useFahrenheit
            ? Int((Double(celsius) * 9 / 5 + 32).rounded())
            : celsius
        return "\(value) °\(useFahrenheit ? "F" : "C")"
    }
}
