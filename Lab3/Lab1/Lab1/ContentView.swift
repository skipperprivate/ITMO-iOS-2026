//
//  ContentView.swift
//  Lab1
//
//  Created by Кирилл Матвеев on 17.09.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var numberText: String = "--"
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(numberText)
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 40)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button {
                        let random = Int.random(in: 1...100)
                        numberText = "\(random)"
                    } label: {
                        Text("Random number")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    NavigationLink {
                        SecondView()
                    } label: {
                        Text("Second View")
                        .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .padding()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
