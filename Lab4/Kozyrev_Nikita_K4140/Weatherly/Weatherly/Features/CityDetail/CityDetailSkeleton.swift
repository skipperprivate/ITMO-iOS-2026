//
//  CityDetailSkeleton.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct CityDetailSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    block(width: 150, height: 88, radius: 20)
                    block(width: 170, height: 18)
                    block(width: 120, height: 26)
                    block(width: 220, height: 18)
                }
                Spacer()
                Circle().fill(WeatherPalette.tileFill).frame(width: 104, height: 104)
            }
            .padding(.bottom, 8)
            block(height: 150, radius: 28)
            HStack(spacing: 12) {
                block(width: 168, height: 176, radius: 28)
                block(width: 168, height: 176, radius: 28)
            }
            block(height: 420, radius: 28)
        }
        .phaseAnimator([0.45, 1.0]) { content, opacity in
            content.opacity(opacity)
        } animation: { _ in
            .easeInOut(duration: 0.9)
        }
        .accessibilityLabel("Загрузка погоды")
    }

    private func block(width: CGFloat? = nil, height: CGFloat, radius: CGFloat = 10) -> some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(WeatherPalette.tileFill)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    CityDetailSkeleton()
        .previewOnBackdrop()
}
#endif
