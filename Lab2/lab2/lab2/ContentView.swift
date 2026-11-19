//
//  ContentView.swift
//  lab2
//
//  Created by FergeS on 20.10.2026.
//

import SwiftUI


struct ContentView: View {
    @State private var number: Int = 0
    
    var body: some View {
        NavigationStack {
            Spacer()
            
            Text("\(number)")
                .font(.largeTitle)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Increase number") {
                    number += 1
                }
                .frame(width: 100, height: 50)
                .background(Color.accentColor)
                .foregroundStyle(Color.white)
                .cornerRadius(10)
                
                Spacer()
                
                NavigationLink("Go to second screen") {
                    SecondView()
                }
                .frame(width: 200, height: 50)
                .background(Color.green)
                .foregroundStyle(Color.white)
                .cornerRadius(10)
                
                Spacer()
                
            }
            
            Spacer()
        }
        
    }
}

#Preview {
    ContentView()
}
