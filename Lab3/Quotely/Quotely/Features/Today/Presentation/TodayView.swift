//
//  TodayView.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 24.09.2026.
//

import SwiftUI

struct TodayView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Цитата дня")
                .font(.largeTitle.bold())

            Text(Quote.preview.text)
                .font(.title2)

            Text(Quote.preview.author)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }
}
