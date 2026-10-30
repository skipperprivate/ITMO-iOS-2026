//
//  GaugeBar.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct GaugeBar: View {
    enum Style { case fill, marker }

    let fraction: Double
    var colors: [Color] = [WeatherPalette.ink]
    var style: Style = .fill

    var body: some View {
        GeometryReader { proxy in
            let clamped = min(max(fraction, 0), 1)
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(WeatherPalette.trackFill)
                switch style {
                case .fill:
                    Capsule()
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(width * clamped, 6))
                case .marker:
                    Capsule()
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    Circle()
                        .fill(.white)
                        .overlay(Circle().strokeBorder(WeatherPalette.ink.opacity(0.4), lineWidth: 1.5))
                        .frame(width: 11, height: 11)
                        .offset(x: (width - 11) * clamped)
                }
            }
        }
        .frame(height: 6)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 24) {
        GaugeBar(fraction: 0.64, colors: [Color(hex: 0x6FC3FF), Color(hex: 0x2F7BEA)])
        GaugeBar(fraction: 0.3, colors: [Color(hex: 0x5CC95C), Color(hex: 0xF5D547), Color(hex: 0xE5484D)], style: .marker)
    }
    .previewOnBackdrop()
}
#endif
