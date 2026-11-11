//
//  WeatherError.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 03.10.2026.
//

import SwiftUI

public struct WeatherError: View {
    
    public let weatherErrorUI: WeatherErrorUI
    public let onReplayButtonClicked: () -> Void

    public init(weatherErrorUI: WeatherErrorUI, onReplayButtonClicked: @escaping () -> Void) {
        self.weatherErrorUI = weatherErrorUI
        self.onReplayButtonClicked = onReplayButtonClicked
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            VStack(spacing: 6) {
                Text("Ошибка загрузки погоды")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(weatherErrorUI.errorDescription.isEmpty ? "Код ошибки: \(weatherErrorUI.errorCode)" : "\(weatherErrorUI.errorDescription) (код: \(weatherErrorUI.errorCode))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            Button {
                onReplayButtonClicked()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Повторить")
                }
                .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding(24)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 24)
    }
}
