//
//  SecondScreen.swift
//  SecondLab
//
//  Created by Egor Kuzminykh on 17.09.2026.
//


import SwiftUI

struct SecondScreen: View {
    var body: some View {
        VStack {
            Text("Это второй экран!")
                .font(.title)
                .foregroundColor(.secondary)
        }
        .navigationTitle("Второй экран")
    }
}
