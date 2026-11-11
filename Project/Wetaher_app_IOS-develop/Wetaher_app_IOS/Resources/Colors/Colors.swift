//
//  Colors.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import SwiftUI

// Семантические цвета интерфейса
public enum Colors {
    // MARK: - Текст
    public static let primaryText = Color.primary
    public static let secondaryText = Color.secondary
    public static let tertiaryText = Color.secondary.opacity(BaseNumeral.tertiaryTextOpacity)

    // MARK: - Фоны
    public static let screenBackground = BaseColors.screenBackground
    public static let cardBackground = BaseColors.cardBackground.opacity(BaseNumeral.cardBackgroundOpacity)
    public static let cardBackgroundStrong = BaseColors.cardBackground.opacity(BaseNumeral.cardBackgroundStrongOpacity)

    // MARK: - Индикаторы состояний
    public static let accent = BaseColors.blue
    public static let onAccent = BaseColors.white
    public static let errorIndicator = BaseColors.orange
    public static let precipitation = BaseColors.blue
    public static let shadow = BaseColors.black.opacity(BaseNumeral.floatingButtonShadowOpacity)
}
