//
//  Cards.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

extension View {
    func glassCard(cornerRadius: CGFloat = 28, padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(WeatherPalette.cardFill, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(WeatherPalette.hairline)
            }
    }

    func weatherScreenStyle() -> some View {
        self
            .foregroundStyle(WeatherPalette.ink)
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct PressableRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.55 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
