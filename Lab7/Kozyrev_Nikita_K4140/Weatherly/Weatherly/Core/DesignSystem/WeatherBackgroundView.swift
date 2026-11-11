//
//  WeatherBackgroundView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct WeatherBackgroundView: View {
    let condition: WeatherCondition?
    let isDaytime: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            gradient
                .id(key)
                .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.6), value: key)
        .ignoresSafeArea()
    }

    private var key: String {
        "\(condition?.rawValue ?? "none")-\(isDaytime)-\(colorScheme == .dark)"
    }

    private var gradient: some View {
        let colors = WeatherPalette.backgroundColors(for: condition, isDaytime: isDaytime, scheme: colorScheme)
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(Color.white.opacity(colorScheme == .light ? 0.45 : (isDaytime ? 0.18 : 0.07)))
                    .frame(width: 340, height: 340)
                    .blur(radius: 100)
                    .offset(x: 110, y: -90)
            }
    }
}

extension View {
    func ambientBackground(_ ambience: WeatherAmbience) -> some View {
        background {
            WeatherBackgroundView(condition: ambience.condition, isDaytime: ambience.isDaytime)
        }
    }
}

#if DEBUG
#Preview {
    WeatherBackgroundView(condition: .partlyCloudy, isDaytime: false)
}
#endif
