//
//  WeatherPalette.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI
import UIKit

// Every token has a light (pastel sky, navy ink) and a dark (deep sky, white ink) variant.
enum WeatherPalette {
    static let ink = Color.dynamic(light: 0x15203A, dark: 0xFFFFFF)
    static let cardFill = Color.dynamic(light: 0xFFFFFF, lightOpacity: 0.5, dark: 0xFFFFFF, darkOpacity: 0.12)
    static let tileFill = Color.dynamic(light: 0xFFFFFF, lightOpacity: 0.45, dark: 0xFFFFFF, darkOpacity: 0.08)
    static let highlightFill = Color.dynamic(light: 0xFFFFFF, lightOpacity: 0.95, dark: 0xFFFFFF, darkOpacity: 0.24)
    // Tinted, not white, so white icons stay visible in the light theme.
    static let nowFill = Color.dynamic(light: 0x2F6FD6, lightOpacity: 0.2, dark: 0xFFFFFF, darkOpacity: 0.24)
    static let fieldFill = Color.dynamic(light: 0xFFFFFF, lightOpacity: 0.72, dark: 0xFFFFFF, darkOpacity: 0.14)
    static let trackFill = Color.dynamic(light: 0x15203A, lightOpacity: 0.08, dark: 0xFFFFFF, darkOpacity: 0.1)
    static let hairline = Color.dynamic(light: 0xFFFFFF, lightOpacity: 0.6, dark: 0xFFFFFF, darkOpacity: 0.08)
    static let shadow = Color.dynamic(light: 0x15203A, lightOpacity: 0.12, dark: 0x000000, darkOpacity: 0.3)
    static let precipitation = Color.dynamic(light: 0x1466C8, dark: 0x8AD8FF)
    static let weekend = Color.dynamic(light: 0xD02F55, dark: 0xFF96A8)
    static let windArrow = Color.dynamic(light: 0x0E9F6E, dark: 0x5BE3A8)
    static let favorite = Color(hex: 0xF5B400)

    static func backgroundColors(for condition: WeatherCondition?, isDaytime: Bool, scheme: ColorScheme) -> [Color] {
        let pair: (top: UInt32, bottom: UInt32)
        switch (condition, scheme) {
        case (nil, .light): pair = (0x9DB3CF, 0xE3EAF3)
        case (nil, _): pair = (0x1F2A44, 0x3B4A6B)
        case (let condition?, .light): pair = lightHex(condition)
        case (let condition?, _): pair = isDaytime ? darkDayHex(condition) : darkNightHex(condition)
        }
        return [Color(hex: pair.top), Color(hex: pair.bottom)]
    }

    private static func lightHex(_ condition: WeatherCondition) -> (top: UInt32, bottom: UInt32) {
        switch condition {
        case .clearSky: (0x6DB3F8, 0xD4EAFF)
        case .mostlyClear: (0x7AB6EE, 0xD9EBFB)
        case .partlyCloudy: (0x8FB2DA, 0xDEE8F3)
        case .cloudy: (0x9EAABB, 0xDFE4EA)
        case .fog: (0xAEB5BF, 0xE6E9EC)
        case .drizzle: (0x8EA6C0, 0xD8E0EA)
        case .rain: (0x7F99B8, 0xD0DAE6)
        case .rainShowers: (0x7289AA, 0xCAD4E2)
        case .snow: (0xAFC5E0, 0xEFF4FA)
        case .thunderstorm: (0x8C88AE, 0xD8D6E8)
        }
    }

    private static func darkDayHex(_ condition: WeatherCondition) -> (top: UInt32, bottom: UInt32) {
        switch condition {
        case .clearSky: (0x2B6FCF, 0x63ACEE)
        case .mostlyClear: (0x3470C4, 0x70A8DF)
        case .partlyCloudy: (0x43669B, 0x7F9FC9)
        case .cloudy: (0x4D5B73, 0x7A889F)
        case .fog: (0x5A6574, 0x8A94A2)
        case .drizzle: (0x394F68, 0x657A92)
        case .rain: (0x2B4160, 0x556B87)
        case .rainShowers: (0x233752, 0x485D7A)
        case .snow: (0x52708F, 0x8CA4BF)
        case .thunderstorm: (0x2A2442, 0x4A4368)
        }
    }

    private static func darkNightHex(_ condition: WeatherCondition) -> (top: UInt32, bottom: UInt32) {
        switch condition {
        case .clearSky, .mostlyClear: (0x121636, 0x2D2F6E)
        case .partlyCloudy: (0x161B3D, 0x343B6F)
        case .cloudy, .fog: (0x1A1F32, 0x3A4058)
        case .drizzle, .rain, .rainShowers: (0x131B2F, 0x2E3B57)
        case .snow: (0x1C2540, 0x40507A)
        case .thunderstorm: (0x110E23, 0x302848)
        }
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    static func dynamic(light: UInt32, lightOpacity: Double = 1, dark: UInt32, darkOpacity: Double = 1) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark, alpha: darkOpacity)
                : UIColor(hex: light, alpha: lightOpacity)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32, alpha: Double) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
