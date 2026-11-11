//
//  BaseAssets.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

extension CityEntity {
    //Для экономии запросов не будем ходить за городами при первой инциализации (без сохранений) на API: вместо этого я переписал все нужные значения из API сюда. Моковая погода далее использоваться по плану не будет и уже ото всюду отключена
    public static let moscow = CityEntity(
        id: 524901,
        name: "Москва",
        country: "Россия",
        latitude: 55.75204,
        longitude: 37.61781,
        timezone: "Europe/Moscow"
    )

    public static let saintPetersburg = CityEntity(
        id: 498817,
        name: "Санкт-Петербург",
        country: "Россия",
        latitude: 59.93863,
        longitude: 30.31413,
        timezone: "Europe/Moscow"
    )

    public static let kazan = CityEntity(
        id: 551487,
        name: "Казань",
        country: "Россия",
        latitude: 55.78874,
        longitude: 49.12214,
        timezone: "Europe/Moscow"
    )

    public static let yekaterinburg = CityEntity(
        id: 1486209,
        name: "Екатеринбург",
        country: "Россия",
        latitude: 56.85733,
        longitude: 60.61529,
        timezone: "Asia/Yekaterinburg"
    )

    public static let novosibirsk = CityEntity(
        id: 1496747,
        name: "Новосибирск",
        country: "Россия",
        latitude: 55.02259,
        longitude: 82.93175,
        timezone: "Asia/Novosibirsk"
    )

    public static let nizhnyNovgorod = CityEntity(
        id: 520555,
        name: "Нижний Новгород",
        country: "Россия",
        latitude: 56.32867,
        longitude: 44.00205,
        timezone: "Europe/Moscow"
    )

    public static let samara = CityEntity(
        id: 499099,
        name: "Самара",
        country: "Россия",
        latitude: 53.20767,
        longitude: 50.13553,
        timezone: "Europe/Samara"
    )

    public static let vladivostok = CityEntity(
        id: 2013348,
        name: "Владивосток",
        country: "Россия",
        latitude: 43.10562,
        longitude: 131.87354,
        timezone: "Asia/Vladivostok"
    )

    public static let kaliningrad = CityEntity(
        id: 554234,
        name: "Калининград",
        country: "Россия",
        latitude: 54.70639,
        longitude: 20.51102,
        timezone: "Europe/Kaliningrad"
    )

    public static let krasnoyarsk = CityEntity(
        id: 1502026,
        name: "Красноярск",
        country: "Россия",
        latitude: 56.03742,
        longitude: 92.93136,
        timezone: "Asia/Krasnoyarsk"
    )

    public static let malmo = CityEntity(
        id: 2692969,
        name: "Мальмё",
        country: "Швеция",
        latitude: 55.60587,
        longitude: 13.00073,
        timezone: "Europe/Stockholm"
    )

    public static let hong_Kong = CityEntity(
        id: 1819729,
        name: "Гонконг",
        country: "HK",
        latitude: 22.27832,
        longitude: 114.17469,
        timezone: "Asia/Hong_Kong"
    )

    /// Список городов по умолчанию для избранного
    public static let defaultFavorites: [CityEntity] = [
        .moscow,
        .saintPetersburg
    ]

    public static let avaliableCities: [CityEntity] = [
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

extension City {
    public static let moscow = CityEntity.moscow.toUI()
    public static let saintPetersburg = CityEntity.saintPetersburg.toUI()
    public static let kazan = CityEntity.kazan.toUI()
    public static let yekaterinburg = CityEntity.yekaterinburg.toUI()
    public static let novosibirsk = CityEntity.novosibirsk.toUI()
    public static let nizhnyNovgorod = CityEntity.nizhnyNovgorod.toUI()
    public static let samara = CityEntity.samara.toUI()
    public static let vladivostok = CityEntity.vladivostok.toUI()
    public static let kaliningrad = CityEntity.kaliningrad.toUI()
    public static let krasnoyarsk = CityEntity.krasnoyarsk.toUI()
    public static let malmo = CityEntity.malmo.toUI()
    public static let hong_Kong = CityEntity.hong_Kong.toUI()

    public static let avaliableCities: [City] = CityEntity.avaliableCities.map { $0.toUI() }
}

extension ForecastUI{
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
            precipProb: 0 //Вероятность осадков
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
