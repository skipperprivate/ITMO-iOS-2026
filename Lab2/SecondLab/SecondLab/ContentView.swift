//
//  ContentView.swift
//  SecondLab
//
//  Created by Egor Kuzminykh on 17.09.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var randomNumber: Int = 42
    @State private var showSecondScreen = false

    var body: some View {
        NavigationStack {
            VStack {
                Text(randomNumber == 42 ? "🎉 Число: \(randomNumber) 🎉" : "Число: \(randomNumber)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(randomNumber == 42 ? .green : .primary)
                    .padding()

                MyButton(title: "Рандомное число", onPressed: someExistingFunction)
                    .padding()
                MyButton(title: "Второй экран", onPressed: goToSecondScreen)
            }
            .navigationDestination(isPresented: $showSecondScreen) {
                SecondScreen()
            }
        }
    }
    func someExistingFunction() {
        self.randomNumber = Int.random(in: 0...42)
    }
    func goToSecondScreen() {
        self.showSecondScreen = true
    }
}
