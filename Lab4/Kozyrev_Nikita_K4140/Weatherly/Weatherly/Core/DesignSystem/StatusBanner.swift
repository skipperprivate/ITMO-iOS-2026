//
//  StatusBanner.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import SwiftUI

// Non-blocking notice over content that stays visible (e.g. a failed refresh of shown data).
struct StatusBanner: View {
    let text: String
    let systemImage: String
    var action: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
            Text(text)
                .font(.wxCaptionBold)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            if action != nil {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12, weight: .bold))
                    .opacity(0.7)
            }
        }
        .foregroundStyle(WeatherPalette.ink)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay { Capsule().strokeBorder(WeatherPalette.hairline) }
        .contentShape(Capsule())
        .onTapGesture { action?() }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(action == nil ? [] : .isButton)
        .accessibilityHint(action == nil ? "" : "Повторить обновление")
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        StatusBanner(text: "Нет сети — показаны прошлые данные", systemImage: "wifi.slash", action: {})
        StatusBanner(text: "Не удалось обновить данные", systemImage: "exclamationmark.triangle")
    }
    .previewOnBackdrop()
}
#endif
