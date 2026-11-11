//
//  BaseAssets.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

extension City {
    // Для экономии запросов не будем ходить за городами при первой инциализации (без сохранений) на API: вместо этого я переписал все нужные значения из API сюда. Моковая погода далее использоваться по плану не будет и уже ото всюду отключена
    public static let moscow = City(
        id: 524901,
        name: "Москва",
        country: "Россия",
        latitude: 55.75204,
        longitude: 37.61781,
        timezone: "Europe/Moscow",
        localTime: CityUIHelper.localTime(timeZone: "Europe/Moscow")
    )

    public static let saintPetersburg = City(
        id: 498817,
        name: "Санкт-Петербург",
        country: "Россия",
        latitude: 59.93863,
        longitude: 30.31413,
        timezone: "Europe/Moscow",
        localTime: CityUIHelper.localTime(timeZone: "Europe/Moscow")
    )

    public static let kazan = City(
        id: 551487,
        name: "Казань",
        country: "Россия",
        latitude: 55.78874,
        longitude: 49.12214,
        timezone: "Europe/Moscow",
        localTime: CityUIHelper.localTime(timeZone: "Europe/Moscow")
    )

    public static let yekaterinburg = City(
        id: 1486209,
        name: "Екатеринбург",
        country: "Россия",
        latitude: 56.85733,
        longitude: 60.61529,
        timezone: "Asia/Yekaterinburg",
        localTime: CityUIHelper.localTime(timeZone: "Asia/Yekaterinburg")
    )

    public static let novosibirsk = City(
        id: 1496747,
        name: "Новосибирск",
        country: "Россия",
        latitude: 55.02259,
        longitude: 82.93175,
        timezone: "Asia/Novosibirsk",
        localTime: CityUIHelper.localTime(timeZone: "Asia/Novosibirsk")
    )

    public static let nizhnyNovgorod = City(
        id: 520555,
        name: "Нижний Новгород",
        country: "Россия",
        latitude: 56.32867,
        longitude: 44.00205,
        timezone: "Europe/Moscow",
        localTime: CityUIHelper.localTime(timeZone: "Europe/Moscow")
    )

    public static let samara = City(
        id: 499099,
        name: "Самара",
        country: "Россия",
        latitude: 53.20767,
        longitude: 50.13553,
        timezone: "Europe/Samara",
        localTime: CityUIHelper.localTime(timeZone: "Europe/Samara")
    )

    public static let vladivostok = City(
        id: 2013348,
        name: "Владивосток",
        country: "Россия",
        latitude: 43.10562,
        longitude: 131.87354,
        timezone: "Asia/Vladivostok",
        localTime: CityUIHelper.localTime(timeZone: "Asia/Vladivostok")
    )

    public static let kaliningrad = City(
        id: 554234,
        name: "Калининград",
        country: "Россия",
        latitude: 54.70639,
        longitude: 20.51102,
        timezone: "Europe/Kaliningrad",
        localTime: CityUIHelper.localTime(timeZone: "Europe/Kaliningrad")
    )

    public static let krasnoyarsk = City(
        id: 1502026,
        name: "Красноярск",
        country: "Россия",
        latitude: 56.03742,
        longitude: 92.93136,
        timezone: "Asia/Krasnoyarsk",
        localTime: CityUIHelper.localTime(timeZone: "Asia/Krasnoyarsk")
    )

    public static let malmo = City(
        id: 2692969,
        name: "Мальмё",
        country: "Швеция",
        latitude: 55.60587,
        longitude: 13.00073,
        timezone: "Europe/Stockholm",
        localTime: CityUIHelper.localTime(timeZone: "Europe/Stockholm")
    )

    public static let hong_Kong = City(
        id: 1819729,
        name: "Гонконг",
        country: "HK",
        latitude: 22.27832,
        longitude: 114.17469,
        timezone: "Asia/Hong_Kong",
        localTime: CityUIHelper.localTime(timeZone: "Asia/Hong_Kong")
    )

    /// Список городов по умолчанию для избранного
    public static let defaultFavorites: [City] = [
        .moscow,
        .saintPetersburg
    ]

    public static let avaliableCities: [City] = [
        .moscow,
        .saintPetersburg,
        .hong_Kong,
        .kaliningrad,
        .kazan,
        .krasnoyarsk,
        .malmo,
        .nizhnyNovgorod,
        .novosibirsk,
        .samara,
        .vladivostok,
        .yekaterinburg
    ]

    func ToResponse() -> CityResponse {
        CityResponse(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            country: country,
            timezone: timezone
        )
    }
}

// Атеншн! Моковые значения у UI и сетевых структур отличаютсяю Учитываем это в тестах
extension ForecastUI {
    public static let moskowWeather = ForecastUI(
        city: .moscow,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 19.3,
            apparentTemp: 18.2,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 7.0,
            windDirection: WeatherUIHelper.degreesToDirection(282),
            windGusts: 18.4,
            relativeHumidity: 54,
            dewPoint: 9.8,
            pressure: 1027.1,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1027.1),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1027.1),
            visibility: 40700.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 40700.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Санкт-Петербург

    public static let saintPetersburgWeather = ForecastUI(
        city: .saintPetersburg,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 13.8,
            apparentTemp: 12.2,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 8.6,
            windDirection: WeatherUIHelper.degreesToDirection(255),
            windGusts: 21.2,
            relativeHumidity: 72,
            dewPoint: 9.1,
            pressure: 1018.4,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1018.4),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1018.4),
            visibility: 18500.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 18500.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Казань

    public static let kazanWeather = ForecastUI(
        city: .kazan,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 16.7,
            apparentTemp: 15.4,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 5.4,
            windDirection: WeatherUIHelper.degreesToDirection(270),
            windGusts: 14.8,
            relativeHumidity: 61,
            dewPoint: 9.1,
            pressure: 1024.6,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1024.6),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1024.6),
            visibility: 26300.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 26300.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Екатеринбург

    public static let yekaterinburgWeather = ForecastUI(
        city: .yekaterinburg,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 10.4,
            apparentTemp: 8.7,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 6.8,
            windDirection: WeatherUIHelper.degreesToDirection(240),
            windGusts: 17.6,
            relativeHumidity: 68,
            dewPoint: 4.8,
            pressure: 1009.8,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1009.8),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1009.8),
            visibility: 14700.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 14700.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Новосибирск

    public static let novosibirskWeather = ForecastUI(
        city: .novosibirsk,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 7.9,
            apparentTemp: 5.1,
            weatherCondition: .weatherConditionsDict[60] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 9.2,
            windDirection: WeatherUIHelper.degreesToDirection(225),
            windGusts: 24.0,
            relativeHumidity: 81,
            dewPoint: 4.6,
            pressure: 1004.2,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1004.2),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1004.2),
            visibility: 9200.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 9200.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Нижний Новгород

    public static let nizhnyNovgorodWeather = ForecastUI(
        city: .nizhnyNovgorod,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 17.2,
            apparentTemp: 15.9,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 6.2,
            windDirection: WeatherUIHelper.degreesToDirection(285),
            windGusts: 16.5,
            relativeHumidity: 58,
            dewPoint: 8.9,
            pressure: 1025.0,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1025.0),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1025.0),
            visibility: 30200.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 30200.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Самара

    public static let samaraWeather = ForecastUI(
        city: .samara,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 18.1,
            apparentTemp: 17.0,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 5.8,
            windDirection: WeatherUIHelper.degreesToDirection(300),
            windGusts: 15.7,
            relativeHumidity: 52,
            dewPoint: 8.3,
            pressure: 1022.8,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1022.8),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1022.8),
            visibility: 35600.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 35600.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Владивосток

    public static let vladivostokWeather = ForecastUI(
        city: .vladivostok,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 14.6,
            apparentTemp: 12.8,
            weatherCondition: .weatherConditionsDict[45] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 11.4,
            windDirection: WeatherUIHelper.degreesToDirection(45),
            windGusts: 28.3,
            relativeHumidity: 77,
            dewPoint: 10.5,
            pressure: 1014.2,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1014.2),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1014.2),
            visibility: 11800.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 11800.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Калининград

    public static let kaliningradWeather = ForecastUI(
        city: .kaliningrad,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 15.8,
            apparentTemp: 14.6,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 9.7,
            windDirection: WeatherUIHelper.degreesToDirection(265),
            windGusts: 23.5,
            relativeHumidity: 70,
            dewPoint: 10.2,
            pressure: 1016.7,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1016.7),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1016.7),
            visibility: 16400.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 16400.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Красноярск

    public static let krasnoyarskWeather = ForecastUI(
        city: .krasnoyarsk,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 8.6,
            apparentTemp: 6.9,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 4.9,
            windDirection: WeatherUIHelper.degreesToDirection(210),
            windGusts: 12.6,
            relativeHumidity: 74,
            dewPoint: 4.2,
            pressure: 1007.3,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1007.3),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1007.3),
            visibility: 12600.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 12600.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Мальмё

    public static let malmoWeather = ForecastUI(
        city: .malmo,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 12.9,
            apparentTemp: 11.1,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 10.3,
            windDirection: WeatherUIHelper.degreesToDirection(250),
            windGusts: 25.7,
            relativeHumidity: 79,
            dewPoint: 9.3,
            pressure: 1012.6,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1012.6),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1012.6),
            visibility: 13900.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 13900.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Гонконг

    public static let hongKongWeather = ForecastUI(
        city: .hong_Kong,
        currentWeather: CurrentWeather(
            date: "2026-10-04",
            time: "15:45",
            temperature: 29.4,
            apparentTemp: 34.1,
            weatherCondition: .weatherConditionsDict[95] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 13.1,
            windDirection: WeatherUIHelper.degreesToDirection(80),
            windGusts: 31.6,
            relativeHumidity: 78,
            dewPoint: 25.0,
            pressure: 1008.9,
            pressureStatus: WeatherUIHelper.pressureStatus(for: 1008.9),
            pressureMmHg: WeatherUIHelper.pressureMmHg(1008.9),
            visibility: 8600.0,
            visibilityStatus: WeatherUIHelper.visibilityStatus(for: 8600.0)
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    private static let hourlyWeatherMockDict = [
        HourlyWeather(
            hour: "00:00",
            temperature: 14.3,
            weatherCondition: WeatherCondition.weatherConditionsDict[3] ?? WeatherCondition.defaultWeatherCondition,
            isDay: false,
            precipProb: 0 // Вероятность осадков
        ),
        HourlyWeather(
            hour: "01:00",
            temperature: 12.4,
            weatherCondition: .weatherConditionsDict[45] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "02:00",
            temperature: 12.0,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 10
        ),
        HourlyWeather(
            hour: "03:00",
            temperature: 11.6,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 10
        ),
        HourlyWeather(
            hour: "04:00",
            temperature: 11.2,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 10
        ),
        HourlyWeather(
            hour: "05:00",
            temperature: 10.8,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "06:00",
            temperature: 10.5,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "07:00",
            temperature: 11.0,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "08:00",
            temperature: 12.2,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 0
        ),
        HourlyWeather(
            hour: "09:00",
            temperature: 13.8,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 0
        ),
        HourlyWeather(
            hour: "10:00",
            temperature: 15.1,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "11:00",
            temperature: 16.4,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "12:00",
            temperature: 17.5,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 0
        ),
        HourlyWeather(
            hour: "13:00",
            temperature: 18.4,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 0
        ),
        HourlyWeather(
            hour: "14:00",
            temperature: 19.0,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "15:00",
            temperature: 19.3,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "16:00",
            temperature: 18.7,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 10
        ),
        HourlyWeather(
            hour: "17:00",
            temperature: 17.6,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 10
        ),
        HourlyWeather(
            hour: "18:00",
            temperature: 16.5,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 15
        ),
        HourlyWeather(
            hour: "19:00",
            temperature: 15.8,
            weatherCondition: .weatherConditionsDict[45] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 20
        ),
        HourlyWeather(
            hour: "20:00",
            temperature: 15.1,
            weatherCondition: .weatherConditionsDict[45] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 20
        ),
        HourlyWeather(
            hour: "21:00",
            temperature: 14.6,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 15
        ),
        HourlyWeather(
            hour: "22:00",
            temperature: 14.1,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 15
        ),
        HourlyWeather(
            hour: "23:00",
            temperature: 13.7,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 5
        )
    ]

    private static let dailyWeatherMockDict = [
        DailyWeather(
            date: "2026-10-04",
            day: "Вс",
            tempMax: 19.8,
            tempMin: 10.4,
            weatherCondition: WeatherCondition.weatherConditionsDict[45] ?? WeatherCondition.defaultWeatherCondition,
            uVIndex: 3.25,
            uvStatus: WeatherUIHelper.uvStatus(for: 3.25),
            sunrise: "2026-10-04T05:12",
            sunset: "2026-10-04T16:36",
            precipProbabilityMean: 0
        ),
        DailyWeather(
            date: "2026-10-05",
            day: "Пн",
            tempMax: 17.6,
            tempMin: 9.8,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            uVIndex: 2.90,
            uvStatus: WeatherUIHelper.uvStatus(for: 2.90),
            sunrise: "2026-10-05T05:14",
            sunset: "2026-10-05T16:33",
            precipProbabilityMean: 10
        ),
        DailyWeather(
            date: "2026-10-06",
            day: "Вт",
            tempMax: 15.2,
            tempMin: 8.7,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            uVIndex: 2.40,
            uvStatus: WeatherUIHelper.uvStatus(for: 2.40),
            sunrise: "2026-10-06T05:16",
            sunset: "2026-10-06T16:30",
            precipProbabilityMean: 20
        ),
        DailyWeather(
            date: "2026-10-07",
            day: "Ср",
            tempMax: 13.8,
            tempMin: 7.9,
            weatherCondition: .weatherConditionsDict[60] ?? .defaultWeatherCondition,
            uVIndex: 1.95,
            uvStatus: WeatherUIHelper.uvStatus(for: 1.95),
            sunrise: "2026-10-07T05:18",
            sunset: "2026-10-07T16:27",
            precipProbabilityMean: 45
        ),
        DailyWeather(
            date: "2026-10-08",
            day: "Чт",
            tempMax: 12.4,
            tempMin: 6.8,
            weatherCondition: .weatherConditionsDict[65] ?? .defaultWeatherCondition,
            uVIndex: 1.75,
            uvStatus: WeatherUIHelper.uvStatus(for: 1.75),
            sunrise: "2026-10-08T05:20",
            sunset: "2026-10-08T16:24",
            precipProbabilityMean: 70
        ),
        DailyWeather(
            date: "2026-10-09",
            day: "Пт",
            tempMax: 14.1,
            tempMin: 7.2,
            weatherCondition: .weatherConditionsDict[67] ?? .defaultWeatherCondition,
            uVIndex: 2.10,
            uvStatus: WeatherUIHelper.uvStatus(for: 2.10),
            sunrise: "2026-10-09T05:22",
            sunset: "2026-10-09T16:21",
            precipProbabilityMean: 55
        ),
        DailyWeather(
            date: "2026-10-10",
            day: "Сб",
            tempMax: 16.7,
            tempMin: 8.9,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            uVIndex: 2.80,
            uvStatus: WeatherUIHelper.uvStatus(for: 2.80),
            sunrise: "2026-10-10T05:24",
            sunset: "2026-10-10T16:18",
            precipProbabilityMean: 5
        )
    ]
}

public extension WeatherResponse {

    static let moscowWeatherResp = WeatherResponse(
        latitude: 55.7558,
        longitude: 37.6173,
        current: .init(
            time: "2026-10-22T19:00",
            temperature2m: 7.4,
            apparentTemperature: 4.8,
            weatherCode: 3,
            isDay: 0,
            windSpeed10m: 14.2,
            windDirection10m: 248,
            windGusts10m: 22.6,
            relativeHumidity2m: 81,
            dewPoint2m: 4.5,
            pressureMsl: 1012.4,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let saintPetersburgWeatherResp = WeatherResponse(
        latitude: 59.9386,
        longitude: 30.3141,
        current: .init(
            time: "2026-10-22T19:00",
            temperature2m: 8.6,
            apparentTemperature: 6.1,
            weatherCode: 61,
            isDay: 0,
            windSpeed10m: 18.4,
            windDirection10m: 262,
            windGusts10m: 29.1,
            relativeHumidity2m: 88,
            dewPoint2m: 6.8,
            pressureMsl: 1006.8,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let hongKongWeatherResp = WeatherResponse(
        latitude: 22.3193,
        longitude: 114.1694,
        current: .init(
            time: "2026-10-23T00:00",
            temperature2m: 27.8,
            apparentTemperature: 31.2,
            weatherCode: 2,
            isDay: 0,
            windSpeed10m: 12.6,
            windDirection10m: 72,
            windGusts10m: 19.4,
            relativeHumidity2m: 76,
            dewPoint2m: 23.1,
            pressureMsl: 1010.2,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let kaliningradWeatherResp = WeatherResponse(
        latitude: 54.7104,
        longitude: 20.4522,
        current: .init(
            time: "2026-10-22T19:00",
            temperature2m: 10.2,
            apparentTemperature: 8.4,
            weatherCode: 3,
            isDay: 0,
            windSpeed10m: 16.8,
            windDirection10m: 231,
            windGusts10m: 26.3,
            relativeHumidity2m: 84,
            dewPoint2m: 7.7,
            pressureMsl: 1008.6,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let kazanWeatherResp = WeatherResponse(
        latitude: 55.7963,
        longitude: 49.1088,
        current: .init(
            time: "2026-10-22T19:00",
            temperature2m: 5.8,
            apparentTemperature: 3.1,
            weatherCode: 2,
            isDay: 0,
            windSpeed10m: 11.7,
            windDirection10m: 287,
            windGusts10m: 18.9,
            relativeHumidity2m: 78,
            dewPoint2m: 2.3,
            pressureMsl: 1015.1,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let krasnoyarskWeatherResp = WeatherResponse(
        latitude: 56.0153,
        longitude: 92.8932,
        current: .init(
            time: "2026-10-22T19:00",
            temperature2m: -1.6,
            apparentTemperature: -5.4,
            weatherCode: 71,
            isDay: 0,
            windSpeed10m: 13.8,
            windDirection10m: 315,
            windGusts10m: 21.7,
            relativeHumidity2m: 86,
            dewPoint2m: -3.8,
            pressureMsl: 1018.3,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let malmoWeatherResp = WeatherResponse(
        latitude: 55.6050,
        longitude: 13.0038,
        current: .init(
            time: "2026-10-22T19:00",
            temperature2m: 9.8,
            apparentTemperature: 7.2,
            weatherCode: 61,
            isDay: 0,
            windSpeed10m: 21.3,
            windDirection10m: 244,
            windGusts10m: 33.6,
            relativeHumidity2m: 89,
            dewPoint2m: 8.1,
            pressureMsl: 1004.7,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let nizhnyNovgorodWeatherResp = WeatherResponse(
        latitude: 56.3269,
        longitude: 44.0059,
        current: .init(
            time: "2026-10-22T19:00",
            temperature2m: 6.2,
            apparentTemperature: 3.6,
            weatherCode: 3,
            isDay: 0,
            windSpeed10m: 12.4,
            windDirection10m: 268,
            windGusts10m: 20.1,
            relativeHumidity2m: 82,
            dewPoint2m: 3.4,
            pressureMsl: 1013.8,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let novosibirskWeatherResp = WeatherResponse(
        latitude: 55.0084,
        longitude: 82.9357,
        current: .init(
            time: "2026-10-22T19:00",
            temperature2m: 0.8,
            apparentTemperature: -2.7,
            weatherCode: 3,
            isDay: 0,
            windSpeed10m: 15.1,
            windDirection10m: 302,
            windGusts10m: 23.8,
            relativeHumidity2m: 84,
            dewPoint2m: -1.6,
            pressureMsl: 1016.9,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let samaraWeatherResp = WeatherResponse(
        latitude: 53.1959,
        longitude: 50.1002,
        current: .init(
            time: "2026-10-22T19:00",
            temperature2m: 8.1,
            apparentTemperature: 5.7,
            weatherCode: 1,
            isDay: 0,
            windSpeed10m: 10.8,
            windDirection10m: 276,
            windGusts10m: 17.2,
            relativeHumidity2m: 74,
            dewPoint2m: 3.8,
            pressureMsl: 1017.2,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let vladivostokWeatherResp = WeatherResponse(
        latitude: 43.1155,
        longitude: 131.8855,
        current: .init(
            time: "2026-10-23T02:00",
            temperature2m: 11.4,
            apparentTemperature: 10.1,
            weatherCode: 2,
            isDay: 0,
            windSpeed10m: 9.6,
            windDirection10m: 348,
            windGusts10m: 15.3,
            relativeHumidity2m: 72,
            dewPoint2m: 6.6,
            pressureMsl: 1014.6,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let yekaterinburgWeatherResp = WeatherResponse(
        latitude: 56.8389,
        longitude: 60.6057,
        current: .init(
            time: "2026-10-22T19:00",
            temperature2m: 3.4,
            apparentTemperature: 0.4,
            weatherCode: 3,
            isDay: 0,
            windSpeed10m: 13.2,
            windDirection10m: 294,
            windGusts10m: 21.0,
            relativeHumidity2m: 80,
            dewPoint2m: 0.4,
            pressureMsl: 1014.2,
            visibility: 10000.0
        ),
        hourly: hourlyWeatherRespMock,
        daily: dailyWeatherResponseMock
        )

    static let hourlyWeatherRespMock = HourlyWeatherResponse(
        time: [
            "2026-10-22T00:00",
            "2026-10-22T01:00",
            "2026-10-22T02:00",
            "2026-10-22T03:00",
            "2026-10-22T04:00",
            "2026-10-22T05:00",
            "2026-10-22T06:00",
            "2026-10-22T07:00",
            "2026-10-22T08:00",
            "2026-10-22T09:00",
            "2026-10-22T10:00",
            "2026-10-22T11:00",
            "2026-10-22T12:00",
            "2026-10-22T13:00",
            "2026-10-22T14:00",
            "2026-10-22T15:00",
            "2026-10-22T16:00",
            "2026-10-22T17:00",
            "2026-10-22T18:00",
            "2026-10-22T19:00",
            "2026-10-22T20:00",
            "2026-10-22T21:00",
            "2026-10-22T22:00",
            "2026-10-22T23:00"
        ],
        temperature2m: [
            5.1, 4.8, 4.6, 4.4, 4.2, 4.1,
            4.4, 5.0, 6.1, 7.2, 8.1, 8.8,
            9.2, 9.4, 9.1, 8.6, 8.0, 7.6,
            7.4, 7.1, 6.8, 6.4, 6.0, 5.6
        ],
        weatherCode: [
            3, 3, 3, 61, 61, 61,
            61, 3, 2, 2, 2, 2,
            3, 3, 3, 3, 3, 3,
            3, 3, 3, 3, 3, 3
        ],
        isDay: [
            0, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1,
            0, 0, 0, 0, 0, 0
        ],
        precipitationProbability: [
            70, 75, 80, 85, 85, 80,
            60, 40, 20, 10, 10, 10,
            20, 20, 25, 30, 30, 30,
            25, 25, 20, 20, 20, 20
        ]
    )

    static let dailyWeatherResponseMock = DailyWeatherResponse(
        time: [
            "2026-10-22",
            "2026-10-23",
            "2026-10-24",
            "2026-10-25",
            "2026-10-26",
            "2026-10-27",
            "2026-10-28"
        ],
        temperature2mMax: [9.4, 8.1, 6.7, 5.2, 4.8, 6.3, 7.9],
        temperature2mMin: [4.1, 3.6, 2.4, 0.8, -0.6, 0.4, 2.1],
        weatherCode: [61, 3, 3, 71, 71, 2, 1],
        uVIndexMax: [1.2, 1.1, 0.9, 0.8, 0.7, 1.0, 1.3],
        sunrise: [
            "07:23",
            "07:25",
            "07:27",
            "07:29",
            "07:31",
            "07:33",
            "07:35"
        ],
        sunset: [
            "17:21",
            "17:18",
            "17:15",
            "17:12",
            "17:10",
            "17:07",
            "17:04"
        ],
        precipitationProbabilityMean: [78, 35, 25, 70, 80, 40, 20]
    )
}
