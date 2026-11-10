//
//  SecondScreen.swift
//  TwoScreens
//
//  Created by Олег Крикунов on 17.09.2026.
//

import SwiftUI

struct SecondView: View {
    var body: some View {
        Text("👽")
            .font(.system(size: 100))
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
    }
}

#Preview {
    SecondView()
}
