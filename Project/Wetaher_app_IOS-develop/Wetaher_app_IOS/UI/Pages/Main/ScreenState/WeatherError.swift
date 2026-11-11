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
        VStack(spacing: BaseNumeral.defaultSpacing) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(Colors.errorIndicator)

            VStack(spacing: BaseNumeral.smallSpacing) {
                Text(BaseText.WeatherError.title)
                    .font(.headline)
                    .foregroundStyle(Colors.primaryText)

                Text(weatherErrorUI.errorDescription.isEmpty
                     ? BaseText.WeatherError.errorCode(weatherErrorUI.errorCode)
                     : BaseText.WeatherError.withCode(weatherErrorUI.errorDescription, code: weatherErrorUI.errorCode))
                    .font(.subheadline)
                    .foregroundStyle(Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            Button {
                onReplayButtonClicked()
            } label: {
                HStack(spacing: BaseNumeral.smallSpacing) {
                    Image(systemName: "arrow.clockwise")
                    Text(BaseText.Common.retry)
                }
                .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, BaseNumeral.textSpacing)
        }
        .padding(BaseNumeral.errorCardPadding)
        .background(Colors.cardBackgroundStrong)
        .clipShape(RoundedRectangle(cornerRadius: BaseNumeral.largeCardCornerRadius, style: .continuous))
        .padding(.horizontal, BaseNumeral.errorCardPadding)
    }
}
