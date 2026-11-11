//
//  BaseText.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

// Строковые константы и статический текст интерфейса
public enum BaseText {
    public enum Common {
        public static let done = "Готово"
        public static let retry = "Повторить"
        public static let delete = "Удалить"
        public static let error = "Ошибка"
        public static let errorLoadingData = "Ошибка загрузки данных"
        public static let loadingData = "Загрузка данных..."
        public static let loadingCities = "Загрузка городов..."
        public static let searching = "Поиск..."
        public static let searchingCities = "Поиск городов..."
    }
    
    public enum Cache {
        public static let withDescription = "Офлайн • Обновлено "
        public static let withoutDescription = "Офлайн-режим (сохранённые данные)"
    }

    public enum Main {
        public static let currentWeatherSeparator = "•"
        public static let hourlyTitle = "ПОЧАСОВОЙ ПРОГНОЗ"
        public static let dailyTitle = "ПРОГНОЗ НА 7 ДНЕЙ"
        public static let hourlyPlaceholder = " "

        public static func maxMin(max: String, min: String) -> String {
            "Макс: \(max), мин: \(min)"
        }

        public static func feelsLike(_ temperature: String) -> String {
            "Ощущается как \(temperature)"
        }
        
        public static let nowWeather = "Сейчас"
    }

    public enum Metrics {
        public static let wind = "Ветер"
        public static let pressure = "Давление"
        public static let humidity = "Влажность"
        public static let uvIndex = "УФ-индекс"
        public static let sunTimes = "Восход и закат"
        public static let sunrise = "Восход"
        public static let sunset = "Закат"
        public static let visibility = "Видимость"
        public static let defaultDirection = "C"

        public static func windDirection(_ direction: String) -> String {
            "Направление: \(direction)"
        }

        public static func windGusts(_ speed: String) -> String {
            "Порывы до \(speed)"
        }

        public static func dewPoint(_ temperature: String) -> String {
            "Точка росы \(temperature)"
        }

        public static func percent(_ value: Int) -> String {
            "\(value)%"
        }
    }

    public enum Cities {
        public static let listTitle = "Избранные города"
        public static let addTitle = "Добавить город"
        public static let searchPrompt = "Поиск по городам"
        public static let loadErrorTitle = "Ошибка загрузки"
        public static let loadErrorMessage = "Не удалось загрузить данные о погоде для сохранённых городов."
        public static let refreshErrorMessage = "Не удалось обновить данные о погоде"
        public static let emptyTitle = "Нет избранных городов"
        public static let emptyMessage = "Нажмите на кнопку «+» внизу, чтобы найти и добавить города."
        public static let searchErrorTitle = "Ошибка поиска"
        public static let searchErrorMessage = "Не удалось выполнить поиск городов. Попробуйте еще раз."
        public static let previousResults = "Результаты предыдущего поиска" //Не удалять строку! Будут использоваться в дальнейшем
        public static let searchResults = "Результаты поиска"
        public static let popular = "Популярные города"
        public static let saved = "В избранном"

        public static func countryAndTime(country: String, time: String) -> String {
            "\(country) • \(time)"
        }

        public static func temperatureRange(max: String, min: String) -> String {
            "\(max) / \(min)"
        }

        public static func error(city: String, description: String) -> String {
            "\(city): \(description)"
        }
    }

    public enum Settings {
        public static let title = "Настройки"
        public static let themePicker = "Тема оформления"
        public static let themeSection = "Тема"
        public static let unitsSection = "Единицы измерения"
        public static let temperature = "Температура"
        public static let temperatureUnit = "°C (Цельсий)"
        public static let windSpeed = "Скорость ветра"
        public static let windSpeedUnit = "м/с (Метры в секунду)"
        public static let pressure = "Давление"
        public static let pressureUnit = "гПа (Гектопаскали)"
        public static let visibility = "Видимость"
        public static let visibilityUnit = "км (Километры)"
    }

    public enum Theme {
        public static let system = "Системная"
        public static let light = "Светлая"
        public static let dark = "Тёмная"
    }

    public enum WeatherError {
        public static let title = "Ошибка загрузки погоды"

        public static func errorCode(_ code: Int) -> String {
            "Код ошибки: \(code)"
        }

        public static func withCode(_ description: String, code: Int) -> String {
            "\(description) (код: \(code))"
        }
    }

    public enum WeatherCondition {
        public static let clear = "Ясно"
        public static let partlyCloudy = "Переменная облачность"
        public static let overcast = "Облачно"
        public static let fog = "Туман"
        public static let drizzle = "Моросящий дождь"
        public static let rain = "Дождь"
        public static let heavyRain = "Ливень"
        public static let sleet = "Мокрый снег"
        public static let snow = "Снег"
        public static let thunderstorm = "Гроза"
    }

    public enum WindDirection {
        public static let north = "С"
        public static let northEast = "СВ"
        public static let east = "В"
        public static let southEast = "ЮВ"
        public static let south = "Ю"
        public static let southWest = "ЮЗ"
        public static let west = "З"
        public static let northWest = "СЗ"

        public static let all = [
            north, northEast, east, southEast, south, southWest, west, northWest
        ]
    }

    public enum UV {
        public static let low = "Низкий"
        public static let moderate = "Умеренный"
        public static let high = "Высокий"
        public static let veryHigh = "Очень высокий"
        public static let extreme = "Экстремальный"
    }

    public enum Pressure {
        public static let normal = "Нормальное"
        public static let high = "Повышенное"
        public static let low = "Пониженное"
    }

    public enum Visibility {
        public static let excellent = "Отличная"
        public static let limited = "Ограниченная"
    }

    public enum Date {
        public static let now = "Сейчас"
        public static let today = "Сегодня"
        public static let tomorrow = "Завтра"
        public static let yesterday = "Вчера"
    }

    public enum Units {
        public static let positiveSign = "+"
        public static let degree = "°"
        public static let windSpeed = "км/ч"
        public static let hectopascals = "гПа"
        public static let millimetersOfMercury = "мм рт. ст."
        public static let kilometers = "км"
    }
}
