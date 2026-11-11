//
//  WeatherIconView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct WeatherIconView: View {
    let condition: WeatherCondition
    let isDaytime: Bool
    var size: CGFloat = 32
    var floats = false

    var body: some View {
        let icon = Image(systemName: condition.symbolName(isDaytime: isDaytime))
            .symbolRenderingMode(.multicolor)
            .font(.system(size: size))
            .weatherIconShadow(size: size)
            .symbolEffect(.bounce, value: condition)
            .accessibilityLabel(condition.label)

        if floats {
            icon.phaseAnimator([false, true]) { content, isUp in
                content.offset(y: isUp ? -size * 0.05 : size * 0.05)
            } animation: { _ in
                .easeInOut(duration: 2.6)
            }
        } else {
            icon
        }
    }
}

private struct WeatherIconShadow: ViewModifier {
    let size: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.shadow(
            color: colorScheme == .light ? Color(hex: 0x15203A, opacity: 0.35) : .clear,
            radius: max(size * 0.07, 2),
            y: max(size * 0.02, 0.5)
        )
    }
}

extension View {
    // White multicolor symbols need a shadow on the pastel light theme.
    func weatherIconShadow(size: CGFloat) -> some View {
        modifier(WeatherIconShadow(size: size))
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        ForEach(WeatherCondition.allCases, id: \.self) { condition in
            HStack(spacing: 24) {
                WeatherIconView(condition: condition, isDaytime: true, size: 36)
                WeatherIconView(condition: condition, isDaytime: false, size: 36)
                Text(condition.label).font(.wxBody)
                Spacer()
            }
        }
    }
    .previewOnBackdrop(isDaytime: true)
}
#endif
