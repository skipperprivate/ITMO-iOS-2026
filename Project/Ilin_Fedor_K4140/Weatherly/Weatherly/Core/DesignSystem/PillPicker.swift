//
//  PillPicker.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI

struct PillPicker<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    let title: (Value) -> String

    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                Button {
                    withAnimation(.snappy(duration: 0.28)) { selection = option }
                } label: {
                    Text(title(option))
                        .font(isSelected ? .wxSubheadlineBold : .wxSubheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(isSelected ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 4)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(WeatherPalette.highlightFill)
                                    .shadow(color: WeatherPalette.shadow, radius: 4, y: 1)
                                    .matchedGeometryEffect(id: "selection", in: namespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(WeatherPalette.trackFill, in: Capsule())
        .sensoryFeedback(.selection, trigger: selection)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        PillPicker(options: WindSpeedUnit.allCases, selection: .constant(.metersPerSecond)) { $0.symbol }
        PillPicker(options: AppTheme.allCases, selection: .constant(.auto)) { $0.label }
    }
    .glassCard()
    .previewOnBackdrop()
}
#endif
