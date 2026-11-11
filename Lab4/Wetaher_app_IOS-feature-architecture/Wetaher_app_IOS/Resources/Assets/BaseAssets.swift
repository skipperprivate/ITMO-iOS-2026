//
//  BaseAssets.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

extension City {
    public static let moscow = City(
        id: 10,
        name: "Москва",
        country: "Россия",
        latitude: 55.752,
        longitude: 37.618,
        timeZoneID: "Europe/Moscow"
    )

    public static let saintPetersburg = City(
        id: 20,
        name: "Санкт-Петербург",
        country: "Россия",
        latitude: 59.939,
        longitude: 30.314,
        timeZoneID: "Europe/Moscow"
    )

    public static let kazan = City(
        id: 30,
        name: "Казань",
        country: "Россия",
        latitude: 55.7887,
        longitude: 49.1221,
        timeZoneID: "Europe/Moscow"
    )

    public static let yekaterinburg = City(
        id: 40,
        name: "Екатеринбург",
        country: "Россия",
        latitude: 56.8389,
        longitude: 60.6057,
        timeZoneID: "Asia/Yekaterinburg"
    )

    public static let novosibirsk = City(
        id: 50,
        name: "Новосибирск",
        country: "Россия",
        latitude: 55.0084,
        longitude: 82.9357,
        timeZoneID: "Asia/Novosibirsk"
    )

    public static let nizhnyNovgorod = City(
        id: 60,
        name: "Нижний Новгород",
        country: "Россия",
        latitude: 56.3269,
        longitude: 44.0059,
        timeZoneID: "Europe/Moscow"
    )

    public static let samara = City(
        id: 70,
        name: "Самара",
        country: "Россия",
        latitude: 53.1959,
        longitude: 50.1002,
        timeZoneID: "Europe/Samara"
    )

    public static let vladivostok = City(
        id: 80,
        name: "Владивосток",
        country: "Россия",
        latitude: 43.1198,
        longitude: 131.8869,
        timeZoneID: "Asia/Vladivostok"
    )

    public static let kaliningrad = City(
        id: 90,
        name: "Калининград",
        country: "Россия",
        latitude: 54.7104,
        longitude: 20.4522,
        timeZoneID: "Europe/Kaliningrad"
    )

    public static let krasnoyarsk = City(
        id: 100,
        name: "Красноярск",
        country: "Россия",
        latitude: 56.0153,
        longitude: 92.8932,
        timeZoneID: "Asia/Krasnoyarsk"
    )
    
    public static let malmo = City(
        id: 110,
        name: "Мальмё",
        country: "Швеция",
        latitude: 55.605,
        longitude: 13.000,
        timeZoneID: "Europe/Stockholm"
    )
    
    public static let hong_Kong = City(
        id: 120,
        name: "Гонконг",
        country: "HK",
        latitude: 22.278,
        longitude: 114.174,
        timeZoneID: "Asia/Hong_Kong"
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
        .moscow,
        .nizhnyNovgorod,
        .novosibirsk,
        .samara,
        .vladivostok,
        .yekaterinburg
    ]
}

extension ForecastUI{
    public static let moskowWeather = ForecastUI(
        city: .moscow,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 19.3,
            apparentTemp: 18.2,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 7.0,
            windDirection: 282, //Идёт с сервера в градусах! (Пока что так, позже напишу маппер)
            windGusts: 18.4,
            relativeHumidity: 54,
            dewPoint: 9.8,
            pressure: 1027.1,
            visibility: 40700.0), //Идёт с сервера в метрах, но в будущем во ViewModel будем конвертировать в КМ
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )
    
    // MARK: - Санкт-Петербург

    public static let saintPetersburgWeather = ForecastUI(
        city: .saintPetersburg,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 13.8,
            apparentTemp: 12.2,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 8.6,
            windDirection: 255,
            windGusts: 21.2,
            relativeHumidity: 72,
            dewPoint: 9.1,
            pressure: 1018.4,
            visibility: 18500.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Казань

    public static let kazanWeather = ForecastUI(
        city: .kazan,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 16.7,
            apparentTemp: 15.4,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 5.4,
            windDirection: 270,
            windGusts: 14.8,
            relativeHumidity: 61,
            dewPoint: 9.1,
            pressure: 1024.6,
            visibility: 26300.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Екатеринбург

    public static let yekaterinburgWeather = ForecastUI(
        city: .yekaterinburg,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 10.4,
            apparentTemp: 8.7,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 6.8,
            windDirection: 240,
            windGusts: 17.6,
            relativeHumidity: 68,
            dewPoint: 4.8,
            pressure: 1009.8,
            visibility: 14700.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Новосибирск

    public static let novosibirskWeather = ForecastUI(
        city: .novosibirsk,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 7.9,
            apparentTemp: 5.1,
            weatherCondition: .weatherConditionsDict[60] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 9.2,
            windDirection: 225,
            windGusts: 24.0,
            relativeHumidity: 81,
            dewPoint: 4.6,
            pressure: 1004.2,
            visibility: 9200.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Нижний Новгород

    public static let nizhnyNovgorodWeather = ForecastUI(
        city: .nizhnyNovgorod,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 17.2,
            apparentTemp: 15.9,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 6.2,
            windDirection: 285,
            windGusts: 16.5,
            relativeHumidity: 58,
            dewPoint: 8.9,
            pressure: 1025.0,
            visibility: 30200.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Самара

    public static let samaraWeather = ForecastUI(
        city: .samara,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 18.1,
            apparentTemp: 17.0,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 5.8,
            windDirection: 300,
            windGusts: 15.7,
            relativeHumidity: 52,
            dewPoint: 8.3,
            pressure: 1022.8,
            visibility: 35600.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Владивосток

    public static let vladivostokWeather = ForecastUI(
        city: .vladivostok,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 14.6,
            apparentTemp: 12.8,
            weatherCondition: .weatherConditionsDict[45] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 11.4,
            windDirection: 45,
            windGusts: 28.3,
            relativeHumidity: 77,
            dewPoint: 10.5,
            pressure: 1014.2,
            visibility: 11800.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Калининград

    public static let kaliningradWeather = ForecastUI(
        city: .kaliningrad,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 15.8,
            apparentTemp: 14.6,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 9.7,
            windDirection: 265,
            windGusts: 23.5,
            relativeHumidity: 70,
            dewPoint: 10.2,
            pressure: 1016.7,
            visibility: 16400.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Красноярск

    public static let krasnoyarskWeather = ForecastUI(
        city: .krasnoyarsk,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 8.6,
            apparentTemp: 6.9,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 4.9,
            windDirection: 210,
            windGusts: 12.6,
            relativeHumidity: 74,
            dewPoint: 4.2,
            pressure: 1007.3,
            visibility: 12600.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Мальмё

    public static let malmoWeather = ForecastUI(
        city: .malmo,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 12.9,
            apparentTemp: 11.1,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 10.3,
            windDirection: 250,
            windGusts: 25.7,
            relativeHumidity: 79,
            dewPoint: 9.3,
            pressure: 1012.6,
            visibility: 13900.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )

    // MARK: - Гонконг

    public static let hongKongWeather = ForecastUI(
        city: .hong_Kong,
        currentWeather: CurrentWeather(
            dateTime: "2026-10-04T15:45",
            temperature: 29.4,
            apparentTemp: 34.1,
            weatherCondition: .weatherConditionsDict[95] ?? .defaultWeatherCondition,
            isDay: true,
            windSpeed: 13.1,
            windDirection: 80,
            windGusts: 31.6,
            relativeHumidity: 78,
            dewPoint: 25.0,
            pressure: 1008.9,
            visibility: 8600.0
        ),
        hourlyWeather: hourlyWeatherMockDict,
        dailyWeather: dailyWeatherMockDict
    )
        
    private static let hourlyWeatherMockDict = [
        HourlyWeather(
            hour: "2026-10-04T00:00",
            temperature: 14.3,
            weatherCondition: WeatherCondition.weatherConditionsDict[3] ?? WeatherCondition.defaultWeatherCondition,
            isDay: false,
            precipProb: 0 //Вероятность осадков
        ),
        HourlyWeather(
            hour: "2026-10-04T01:00",
            temperature: 12.4,
            weatherCondition: .weatherConditionsDict[45] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "2026-10-04T02:00",
            temperature: 12.0,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 10
        ),
        HourlyWeather(
            hour: "2026-10-04T03:00",
            temperature: 11.6,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 10
        ),
        HourlyWeather(
            hour: "2026-10-04T04:00",
            temperature: 11.2,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 10
        ),
        HourlyWeather(
            hour: "2026-10-04T05:00",
            temperature: 10.8,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "2026-10-04T06:00",
            temperature: 10.5,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "2026-10-04T07:00",
            temperature: 11.0,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "2026-10-04T08:00",
            temperature: 12.2,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 0
        ),
        HourlyWeather(
            hour: "2026-10-04T09:00",
            temperature: 13.8,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 0
        ),
        HourlyWeather(
            hour: "2026-10-04T10:00",
            temperature: 15.1,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "2026-10-04T11:00",
            temperature: 16.4,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "2026-10-04T12:00",
            temperature: 17.5,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 0
        ),
        HourlyWeather(
            hour: "2026-10-04T13:00",
            temperature: 18.4,
            weatherCondition: .weatherConditionsDict[0] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 0
        ),
        HourlyWeather(
            hour: "2026-10-04T14:00",
            temperature: 19.0,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "2026-10-04T15:00",
            temperature: 19.3,
            weatherCondition: .weatherConditionsDict[2] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 5
        ),
        HourlyWeather(
            hour: "2026-10-04T16:00",
            temperature: 18.7,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: true,
            precipProb: 10
        ),
        HourlyWeather(
            hour: "2026-10-04T17:00",
            temperature: 17.6,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 10
        ),
        HourlyWeather(
            hour: "2026-10-04T18:00",
            temperature: 16.5,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 15
        ),
        HourlyWeather(
            hour: "2026-10-04T19:00",
            temperature: 15.8,
            weatherCondition: .weatherConditionsDict[45] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 20
        ),
        HourlyWeather(
            hour: "2026-10-04T20:00",
            temperature: 15.1,
            weatherCondition: .weatherConditionsDict[45] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 20
        ),
        HourlyWeather(
            hour: "2026-10-04T21:00",
            temperature: 14.6,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 15
        ),
        HourlyWeather(
            hour: "2026-10-04T22:00",
            temperature: 14.1,
            weatherCondition: .weatherConditionsDict[3] ?? .defaultWeatherCondition,
            isDay: false,
            precipProb: 15
        ),
        HourlyWeather(
            hour: "2026-10-04T23:00",
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
            sunrise: "2026-10-10T05:24",
            sunset: "2026-10-10T16:18",
            precipProbabilityMean: 5
        )
    ]
}
