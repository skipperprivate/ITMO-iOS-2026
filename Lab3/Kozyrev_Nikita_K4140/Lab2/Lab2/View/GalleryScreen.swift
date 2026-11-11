//
//  GalleryScreen.swift
//  Lab2
//
//  Created by Nikita Kozyrev on 17.09.2026.
//

import SwiftUI

struct GalleryScreen: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Второй экран")
                .font(.largeTitle.weight(.semibold))

            Image("extra")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 40)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GalleryScreen()
    }
}
