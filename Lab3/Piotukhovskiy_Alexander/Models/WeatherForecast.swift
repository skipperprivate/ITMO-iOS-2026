struct WeatherForecast {
    let city: String
    let currentTemperature: Int
    let currentCondition: String
    let hourly: [HourForecast]
    let daily: [DayForecast]
}
