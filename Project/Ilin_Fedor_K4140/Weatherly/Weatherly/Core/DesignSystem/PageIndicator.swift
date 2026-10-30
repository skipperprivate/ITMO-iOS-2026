//
//  PageIndicator.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(WeatherPalette.ink.opacity(index == currentIndex ? 0.9 : 0.3))
                    .frame(width: index == currentIndex ? 12 : 5, height: 5)
            }
        }
        .animation(.snappy, value: currentIndex)
        .accessibilityElement()
        .accessibilityLabel("Город \(currentIndex + 1) из \(count)")
    }
}

#if DEBUG
#Preview {
    PageIndicator(count: 4, currentIndex: 1)
        .previewOnBackdrop()
}
#endif
