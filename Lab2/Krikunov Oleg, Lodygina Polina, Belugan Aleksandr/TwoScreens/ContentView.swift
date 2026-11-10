//
//  ContentView.swift
//  TwoScreens
//
//  Created by Олег Крикунов on 17.09.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var number = Int.random(in: 1...1000)

    var body: some View {
        NavigationStack {
            VStack {
                Text("\(number)")
                    .font(.system(size: 64, weight: .bold))
                    .padding(.top, 32)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        number = Int.random(in: 1...1000)
                    } label: {
                        Text("Сгенерировать новое число")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink {
                        SecondView()
                    } label: {
                        Text("Второй экран")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    ContentView()
}
