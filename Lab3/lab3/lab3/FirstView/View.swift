//
//  View.swift
//  lab3
//
//  Created by FergeS on 20.10.2026.
//

import SwiftUI

struct FirstView: View {
    @State private var viewModel = FirstViewModel()
    
    var body: some View {
        NavigationStack {
            Spacer()
            
            Text("\(viewModel.number)")
                .font(.largeTitle)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Increase number") {
                    viewModel.increase()
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
    FirstView()
}
