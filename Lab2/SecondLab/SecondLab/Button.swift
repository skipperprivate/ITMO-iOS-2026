//
//  Button.swift
//  SecondLab
//
//  Created by Egor Kuzminykh on 17.09.2026.
//
import SwiftUI
struct MyButton: View {
    let title: String
    let onPressed: () -> Void
    var body: some View {
        VStack {
            Button(action:
                onPressed
            ){
                Text(title)
            }.buttonStyle(.borderedProminent)
                .controlSize(.large)               
                .tint(.blue)
        }
    }
}
