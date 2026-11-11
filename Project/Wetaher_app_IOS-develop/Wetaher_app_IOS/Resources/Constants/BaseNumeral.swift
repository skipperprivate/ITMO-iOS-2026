//
//  BaseNumeral.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import CoreGraphics

// Числовые константы интерфейса: отступы, интервалы, размеры, шрифты и прозрачность
public enum BaseNumeral {
    // MARK: - Отступы
    public static let screenHorizontalPadding: CGFloat = 16
    public static let screenBottomPadding: CGFloat = 24
    public static let cardPadding: CGFloat = 12
    public static let errorCardPadding: CGFloat = 24
    public static let bottomButtonPadding: CGFloat = 16
    public static let iconButtonPadding: CGFloat = 8
    public static let controlPanelHorizontalPadding: CGFloat = 20
    public static let listRowVerticalInset: CGFloat = 4
    public static let currentTemperatureVerticalPadding: CGFloat = -8

    // MARK: - Интервалы
    public static let textSpacing: CGFloat = 4
    public static let smallSpacing: CGFloat = 8
    public static let defaultSpacing: CGFloat = 12
    public static let sectionSpacing: CGFloat = 16
    public static let wideSpacing: CGFloat = 20

    // MARK: - Скругления
    public static let cardCornerRadius: CGFloat = 12
    public static let largeCardCornerRadius: CGFloat = 16

    // MARK: - Размеры
    public static let metricCardMinHeight: CGFloat = 110
    public static let columnWidth: CGFloat = 72
    public static let controlSize: CGFloat = 56
    public static let iconHeight: CGFloat = 24

    // MARK: - Шрифты
    public static let cityNameFontSize: CGFloat = 32
    public static let currentTemperatureFontSize: CGFloat = 84
    public static let cityCardTemperatureFontSize: CGFloat = 38
    public static let errorIconFontSize: CGFloat = 28
    public static let precipitationIconFontSize: CGFloat = 8
    public static let captionFontSize: CGFloat = 12

    // MARK: - Анимации
    public static let backgroundAnimationDuration: Double = 0.35

    // MARK: - Тени
    public static let floatingButtonShadowRadius: CGFloat = 8
    public static let floatingButtonShadowY: CGFloat = 4
    public static let floatingButtonShadowOpacity: Double = 0.2

    // MARK: - Прозрачность
    public static let tertiaryTextOpacity: Double = 0.35
    public static let cardBackgroundOpacity: Double = 0.8
    public static let cardBackgroundStrongOpacity: Double = 0.85
    public static let dividerOpacity: Double = 0.4
    public static let dimmedIconOpacity: Double = 0.9

    // MARK: - Поиск
    public static let searchDebounceDuration: UInt64 = 300_000_000
}
