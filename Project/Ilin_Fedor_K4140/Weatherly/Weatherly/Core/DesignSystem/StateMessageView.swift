//
//  StateMessageView.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import SwiftUI

// Full-area message when there is nothing else to show (failure, no results, no data);
// a failure over data that is still shown gets StatusBanner instead.
struct StateMessageView: View {
    let title: String
    let message: String
    let systemImage: String
    var retry: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)
            Text(title)
                .font(.wxTitle3)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.wxSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let retry {
                Button {
                    retry()
                } label: {
                    Text("Повторить")
                }
                .font(.wxSubheadlineBold)
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .padding(.top, 6)
            }
        }
        .frame(maxWidth: 320)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }
}

#if DEBUG
#Preview {
    StateMessageView(
        title: "Нет подключения к интернету",
        message: "Проверьте сеть — мы обновим данные, как только она появится",
        systemImage: "wifi.slash",
        retry: {}
    )
    .previewOnBackdrop()
}
#endif
