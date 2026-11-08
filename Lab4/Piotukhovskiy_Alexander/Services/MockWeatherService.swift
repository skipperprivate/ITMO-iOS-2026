import Foundation

enum MockWeatherError: Error {
    case updateFailed
}

@MainActor
struct MockWeatherService: WeatherService {
    private let delay: Duration
    private let roll: () -> Int
    private let now: () -> Date
    private let codes = [0, 1, 2, 3, 45, 61, 63, 71, 80, 95]

    init(delay: Duration = AppConstants.mockDelay,
         roll: @escaping () -> Int = { Int.random(in: 1...10) },
         now: @escaping () -> Date = { Date() }) {
        self.delay = delay
        self.roll = roll
        self.now = now
    }

    func forecast(for city: City, reason: ForecastLoadReason) async throws -> WeatherForecast {
        try await Task.sleep(for: delay)
        try Task.checkCancellation()

        if reason == .userRefresh {
            let value = roll()
            if value == 4 || value == 8 { throw MockWeatherError.updateFailed }
        }

        let loadedAt = now()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = city.displayTimeZone
        let firstHour = calendar.dateInterval(of: .hour, for: loadedAt)?.start ?? loadedAt
        let firstDay = calendar.startOfDay(for: loadedAt)
        let temperature = Double.random(in: -10...30)
        let code = codes.randomElement() ?? 0
        let currentIsDay = isDay(loadedAt, calendar: calendar)

        let hourly = (0..<AppConstants.hourlyForecastCount).map { index in
            let date = calendar.date(byAdding: .hour, value: index, to: firstHour)!
            return HourForecast(date: date,
                                temperature: index == 0 ? temperature : temperature + Double.random(in: -4...4),
                                weatherCode: index == 0 ? code : (codes.randomElement() ?? 0),
                                isDay: isDay(date, calendar: calendar))
        }
        let daily = (0..<AppConstants.dailyForecastCount).map { index in
            DayForecast(date: calendar.date(byAdding: .day, value: index, to: firstDay)!,
                        minimum: temperature - Double.random(in: 2...8),
                        maximum: temperature + Double.random(in: 0...6),
                        weatherCode: index == 0 ? code : (codes.randomElement() ?? 0))
        }
        return WeatherForecast(cityID: city.id,
                               timezone: city.timezone ?? "GMT",
                               current: CurrentWeather(date: loadedAt, temperature: temperature,
                                                       weatherCode: code, isDay: currentIsDay),
                               hourly: hourly, daily: daily, loadedAt: loadedAt)
    }

    private func isDay(_ date: Date, calendar: Calendar) -> Bool {
        (6..<20).contains(calendar.component(.hour, from: date))
    }
}
