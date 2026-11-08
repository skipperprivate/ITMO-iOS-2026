struct MockWeatherService {
    private let conditions = ["Sun", "Clouds", "Rain", "Snow"]

    func forecast(for city: String) -> WeatherForecast {
        let currentTemperature = Int.random(in: -10...30)
        let currentCondition = conditions.randomElement() ?? "Sun"

        let hourly = (0..<8).map { index in
            HourForecast(
                title: index == 0 ? "Now" : "In \(index) h",
                temperature: index == 0
                    ? currentTemperature
                    : currentTemperature + Int.random(in: -4...4),
                condition: index == 0
                    ? currentCondition
                    : (conditions.randomElement() ?? "Sun")
            )
        }

        let daily = (0..<5).map { index in
            let day = index == 0 ? "Today" : (index == 1 ? "Tomorrow" : "In \(index) days")
            let minimum = currentTemperature - Int.random(in: 2...8)
            let maximum = currentTemperature + Int.random(in: 0...6)

            return DayForecast(
                title: day,
                minimum: minimum,
                maximum: maximum,
                condition: index == 0
                    ? currentCondition
                    : (conditions.randomElement() ?? "Sun")
            )
        }

        return WeatherForecast(
            city: city,
            currentTemperature: currentTemperature,
            currentCondition: currentCondition,
            hourly: hourly,
            daily: daily
        )
    }
}
