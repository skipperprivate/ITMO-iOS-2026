//
//  WeatherDescriptions.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

enum WeatherDescriptions {
    static func wind(kmh: Double) -> String {
        switch kmh / 3.6 {
        case ..<0.5: "Штиль"
        case ..<4: "Слабый ветер"
        case ..<8: "Умеренный ветер"
        case ..<14: "Сильный ветер"
        case ..<21: "Очень сильный ветер"
        default: "Шторм"
        }
    }

    // Direction the wind blows from.
    static func compassDirection(degrees: Double) -> String {
        let names = ["С", "СВ", "В", "ЮВ", "Ю", "ЮЗ", "З", "СЗ"]
        let normalized = (degrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        return names[Int((normalized + 22.5) / 45) % names.count]
    }

    static func humidity(_ percent: Int) -> String {
        switch percent {
        case ..<30: "Сухо"
        case ...60: "Комфортно"
        case ...80: "Влажно"
        default: "Очень влажно"
        }
    }

    static func pressure(hPa: Double) -> String {
        switch hPa {
        case ..<1005: "Пониженное"
        case ...1022: "Нормальное"
        default: "Повышенное"
        }
    }

    static func uvIndex(_ value: Double) -> String {
        switch value {
        case ..<3: "Низкий"
        case ..<6: "Умеренный"
        case ..<8: "Высокий"
        case ..<11: "Очень высокий"
        default: "Экстремальный"
        }
    }

    static func visibility(km: Double) -> String {
        switch km {
        case ..<1: "Плохая"
        case ..<5: "Средняя"
        case ..<10: "Хорошая"
        default: "Отличная"
        }
    }
}
