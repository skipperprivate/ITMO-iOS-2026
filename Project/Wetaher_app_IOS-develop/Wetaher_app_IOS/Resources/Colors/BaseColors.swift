//
//  BaseColors.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import SwiftUI

// Базовая палитра приложения: системные оттенки и цвета погодных градиентов
public enum BaseColors {
    // MARK: - Системные оттенки
    public static let gray = Color.gray
    public static let orange = Color.orange
    public static let indigo = Color.indigo
    public static let yellow = Color.yellow
    public static let cyan = Color.cyan
    public static let blue = Color.blue
    public static let teal = Color.teal
    public static let green = Color.green
    public static let red = Color.red
    public static let purple = Color.purple
    public static let white = Color.white
    public static let black = Color.black
    public static let secondary = Color.secondary

    // MARK: - Системные фоны
    public static let screenBackground = Color(uiColor: .systemGroupedBackground)
    public static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)

    // MARK: - Погодные градиенты

    // Ясно
    public static let clearSkyDarkDay: [Color] = [
        Color(red: 0.13, green: 0.17, blue: 0.24),
        Color(red: 0.08, green: 0.10, blue: 0.15)
    ]
    public static let clearSkyDarkNight: [Color] = [
        Color(red: 0.08, green: 0.10, blue: 0.18),
        Color(red: 0.05, green: 0.06, blue: 0.11)
    ]
    public static let clearSkyLightDay: [Color] = [
        Color(red: 0.88, green: 0.94, blue: 1.0),
        Color(red: 0.95, green: 0.97, blue: 1.0)
    ]
    public static let clearSkyLightNight: [Color] = [
        Color(red: 0.90, green: 0.92, blue: 0.97),
        Color(red: 0.95, green: 0.95, blue: 0.98)
    ]

    // Переменная облачность
    public static let partlyCloudyDarkDay: [Color] = [
        Color(red: 0.14, green: 0.17, blue: 0.22),
        Color(red: 0.09, green: 0.11, blue: 0.15)
    ]
    public static let partlyCloudyDarkNight: [Color] = [
        Color(red: 0.10, green: 0.11, blue: 0.18),
        Color(red: 0.06, green: 0.07, blue: 0.12)
    ]
    public static let partlyCloudyLightDay: [Color] = [
        Color(red: 0.90, green: 0.94, blue: 0.98),
        Color(red: 0.95, green: 0.97, blue: 0.99)
    ]
    public static let partlyCloudyLightNight: [Color] = [
        Color(red: 0.91, green: 0.92, blue: 0.97),
        Color(red: 0.95, green: 0.96, blue: 0.98)
    ]

    // Облачно и туман
    public static let overcastDark: [Color] = [
        Color(white: 0.16),
        Color(white: 0.10)
    ]
    public static let overcastLight: [Color] = [
        Color(red: 0.91, green: 0.93, blue: 0.95),
        Color(red: 0.95, green: 0.96, blue: 0.98)
    ]

    // Дождь
    public static let rainDark: [Color] = [
        Color(red: 0.11, green: 0.15, blue: 0.22),
        Color(red: 0.07, green: 0.09, blue: 0.14)
    ]
    public static let rainLight: [Color] = [
        Color(red: 0.88, green: 0.92, blue: 0.96),
        Color(red: 0.94, green: 0.96, blue: 0.98)
    ]

    // Снег
    public static let snowDark: [Color] = [
        Color(red: 0.13, green: 0.17, blue: 0.21),
        Color(red: 0.08, green: 0.11, blue: 0.14)
    ]
    public static let snowLight: [Color] = [
        Color(red: 0.91, green: 0.95, blue: 0.99),
        Color(red: 0.96, green: 0.98, blue: 1.0)
    ]

    // Гроза
    public static let thunderstormDark: [Color] = [
        Color(red: 0.14, green: 0.13, blue: 0.20),
        Color(red: 0.08, green: 0.07, blue: 0.13)
    ]
    public static let thunderstormLight: [Color] = [
        Color(red: 0.89, green: 0.90, blue: 0.96),
        Color(red: 0.94, green: 0.95, blue: 0.98)
    ]
}
