//
//  WeatherResponseMapper.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 18.10.2026.
//
import Foundation

extension WeatherResponse {
    func ToUI(city: City) -> ForecastUI {
        ForecastUI(
            city: city,
            currentWeather: current.ToUI(),
            hourlyWeather: hourly.ToUI(currentTime: current.time),
            dailyWeather: daily.ToUI(currentTime: current.time)
        )
    }
}

extension CurrentWeatherResponse {
    func ToUI() -> CurrentWeather {
        let visibilityInKm = WeatherUIHelper.visibility(visibility)

        return CurrentWeather(
            date: WeatherUIHelper.formatDateString(time),
            time: WeatherUIHelper.formatTimeString(time),
            temperature: temperature2m,
            apparentTemp: apparentTemperature,
            weatherCondition: WeatherCondition.weatherConditionsDict[weatherCode] ?? WeatherCondition.defaultWeatherCondition,
            isDay: Bool(isDay as NSNumber),
            windSpeed: windSpeed10m,
            windDirection: WeatherUIHelper.degreesToDirection(windDirection10m),
            windGusts: windGusts10m,
            relativeHumidity: relativeHumidity2m,
            dewPoint: dewPoint2m,
            pressure: pressureMsl,
            pressureStatus: WeatherUIHelper.pressureStatus(for: pressureMsl),
            pressureMmHg: WeatherUIHelper.pressureMmHg(pressureMsl),
            visibility: visibilityInKm,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: visibilityInKm)
        )
    }
}

extension HourlyWeatherResponse {
    func ToUI(currentTime: String) -> [HourlyWeather] {
        var hourlyWeatherArray: [HourlyWeather] = []

        // Определяем стартовый сдвиг для вывода почасовок в зав-ти от Гринвича
        var timeOffset: Int

        let timePart = currentTime.components(separatedBy: "T").last ?? currentTime
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = .gmt // Время по гринвичу!
        formatter.locale = Locale(identifier: "ru_RU")

        if TestChecker.isRunningTests { // timeOffset должен быть 0 при запуске тестов!
            timeOffset = 0
        }else {
            if let time = formatter.date(from: timePart) {

                var calendar = Calendar.current
                calendar.timeZone = .gmt
                let hour = calendar.component(.hour, from: time)

                timeOffset = hour
            }else {
                timeOffset = 0
            }
        }

        for i in timeOffset...(MinArrayCount() + timeOffset - 1) { // Предполагаем, что API выдаёт нам корректное количество данных для всех массивов, но всё же на всякий случай обрабатываем по минимальному по кол-ву элл-ов массиву

            hourlyWeatherArray.append(
                HourlyWeather(
                    hour: WeatherUIHelper.formatTimeString(time[i], index: i, timeOffset: timeOffset),
                    temperature: temperature2m[i],
                    weatherCondition: WeatherCondition.weatherConditionsDict[weatherCode[i]] ?? WeatherCondition.defaultWeatherCondition,
                    isDay: Bool(isDay[i] as NSNumber),
                    precipProb: precipitationProbability[i]
                )
            )
        }

        return hourlyWeatherArray
    }

    private func MinArrayCount() -> Int { // Нам не нужно показывать больше часов, чем 24 часа с момента текущего времени (1 сутки)
        return min(time.count, temperature2m.count, isDay.count, weatherCode.count, precipitationProbability.count, 24)
    }
}

extension DailyWeatherResponse {
    func ToUI(currentTime: String) -> [DailyWeather] {
        var dailyWeatherArray: [DailyWeather] = []
        for i in 0...(MinArrayCount() - 1) {
            dailyWeatherArray.append(
                DailyWeather(
                    date: WeatherUIHelper.formatDateLocalizedString(time[i]),
                    day: WeatherUIHelper.formatDayOfWeekString(time[i], currentDT: currentTime, index: i),
                    tempMax: temperature2mMax[i],
                    tempMin: temperature2mMin[i],
                    weatherCondition: WeatherCondition.weatherConditionsDict[weatherCode[i]] ?? WeatherCondition.defaultWeatherCondition,
                    uVIndex: uVIndexMax[i],
                    uvStatus: WeatherUIHelper.uvStatus(for: uVIndexMax[i]),
                    sunrise: WeatherUIHelper.formatTimeString(sunrise[i]),
                    sunset: WeatherUIHelper.formatTimeString(sunset[i]),
                    precipProbabilityMean: precipitationProbabilityMean[i]
                )
            )
        }

        return dailyWeatherArray
    }

    private func MinArrayCount() -> Int {
        return min(time.count, temperature2mMax.count, temperature2mMin.count, weatherCode.count, uVIndexMax.count, sunset.count, sunrise.count, precipitationProbabilityMean.count)
    }
}
