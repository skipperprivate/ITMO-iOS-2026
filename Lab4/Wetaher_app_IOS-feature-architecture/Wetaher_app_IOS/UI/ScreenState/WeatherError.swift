//
//  WeatherError.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 03.10.2026.
//

import SwiftUI

struct WeatherError: View {
    
    var weatherErrorUI: WeatherErrorUI
    let onReplayButtonClicked: () -> Void
    
    init(weatherErrorUI: WeatherErrorUI, onReplayButtonClicked: @escaping () -> Void) {
        self.weatherErrorUI = weatherErrorUI
        self.onReplayButtonClicked = onReplayButtonClicked
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text("\(weatherErrorUI.errorCode) " + weatherErrorUI.errorDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Повторить") {
                onReplayButtonClicked()
            }
            .buttonStyle(.bordered)
        }
    }
}
