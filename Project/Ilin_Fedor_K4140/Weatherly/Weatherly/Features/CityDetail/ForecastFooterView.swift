//
//  ForecastFooterView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import SwiftUI

// Data age plus the CC BY credit Open-Meteo requires next to its data.
struct ForecastFooterView: View {
    let updatedAt: Date?
    let now: Date

    var body: some View {
        VStack(spacing: 4) {
            if let updatedAt {
                Text(WeatherFormatter.updated(at: updatedAt, now: now))
            }
            Link(destination: DataAttribution.url) {
                Text("\(DataAttribution.title) · \(DataAttribution.license)")
                    .underline()
            }
        }
        .font(.wxCaption)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.top, 6)
    }
}

#if DEBUG
#Preview {
    ForecastFooterView(updatedAt: .now.addingTimeInterval(-300), now: .now)
        .previewOnBackdrop()
}
#endif
