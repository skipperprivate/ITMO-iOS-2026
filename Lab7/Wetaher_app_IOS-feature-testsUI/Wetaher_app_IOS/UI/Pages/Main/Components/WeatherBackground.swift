//
//  WeatherBackground.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

/// Фон, адаптирующийся под погодные условия и тему
public struct WeatherBackground: View {
    public let condition: WeatherCondition?
    public let isDay: Bool
    @Environment(\.colorScheme) private var colorScheme

    public init(condition: WeatherCondition? = nil, isDay: Bool = true) {
        self.condition = condition
        self.isDay = isDay
    }

    public var body: some View {
        ZStack {
            // Базовый цвет подложки
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            // Градиент погодных условий
            if let condition {
                let diff = (colorScheme == .dark) ? condition.backgroundColorsDarkTheme : condition.backgroundColorsLightTheme
                let colors: [Color] = {
                    switch diff {
                    case .single(let list):
                        return list
                    case .pair(let dayColors, let nightColors):
                        return isDay ? dayColors : nightColors
                    }
                }()

                LinearGradient(
                    colors: colors,
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.35), value: condition)
                .animation(.easeInOut(duration: 0.35), value: colorScheme)
            }
        }
    }
}
